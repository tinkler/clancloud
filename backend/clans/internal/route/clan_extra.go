package route

import (
	"net/http"
	"strconv"

	"github.com/go-chi/chi/v5"
	"github.com/tinkler/clancloud/backend/clans/internal/model/clan"
	"github.com/tinkler/mqttadmin/pkg/jsonz/sjson"
	"github.com/tinkler/mqttadmin/pkg/status"
)

func RoutesClanExtra(m chi.Router) {
	m.Route("/clan_extra", func(r chi.Router) {
		r.Post("/member/upload-profile-picture", func(w http.ResponseWriter, r *http.Request) {
			// Parse the multipart form, 10 << 20 specifies a maximum upload of 10 MB files.
			if err := r.ParseMultipartForm(10 << 20); err != nil {
				http.Error(w, err.Error(), http.StatusBadRequest)
				return
			}

			memberIds := r.FormValue("member_id")
			if memberIds == "" {
				status.HttpError(w, status.New(http.StatusBadRequest, "member_id is required"))
				return
			}
			memberId, err := strconv.ParseInt(memberIds, 10, 64)
			if err != nil {
				status.HttpError(w, status.New(http.StatusBadRequest, "member_id is invalid"))
				return
			}
			if memberId == 0 {
				status.HttpError(w, status.New(http.StatusBadRequest, "member_id is invalid"))
				return
			}

			file, handler, err := r.FormFile("uploads")
			if err != nil {
				http.Error(w, err.Error(), http.StatusBadRequest)
				return
			}
			defer file.Close()

			fileName := handler.Filename
			if fileName == "" {
				status.HttpError(w, status.New(http.StatusBadRequest, "filename is required"))
				return
			}

			if handler.Size == 0 {
				status.HttpError(w, status.New(http.StatusBadRequest, "file is empty"))
				return
			}

			m := &clan.Member{ID: memberId}
			err = m.UploadProfilePicture(r.Context(), file, fileName)
			if status.HttpError(w, err) {
				return
			}
			res := Res[*clan.Member, any]{
				Data: m,
			}
			if sjson.HttpWrite(w, res) {
				return
			}
		})
	})
}
