package route

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/tinkler/clancloud/backend/memorial/internal/model/memorial"
	"github.com/tinkler/mqttadmin/pkg/jsonz/sjson"
	"github.com/tinkler/mqttadmin/pkg/status"
)

func RoutesMemorialExtra(m chi.Router) {
	m.Route("/memorial_extra", func(r chi.Router) {
		r.Post("/memorial/upload-memorial-picture", func(w http.ResponseWriter, r *http.Request) {
			// Parse the multipart form, 10 << 20 specifies a maximum upload of 10 MB files.
			if err := r.ParseMultipartForm(10 << 20); err != nil {
				http.Error(w, err.Error(), http.StatusBadRequest)
				return
			}

			memorialIds := r.FormValue("memorial_id")
			if memorialIds == "" {
				status.HttpError(w, status.New(http.StatusBadRequest, "memorial_id is required"))
				return
			}
			if len(memorialIds) == 0 {
				status.HttpError(w, status.New(http.StatusBadRequest, "memorial_id is invalid"))
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

			m := &memorial.Memorial{ID: memorialIds}
			err = m.UploadPicture(r.Context(), file, fileName)
			if status.HttpError(w, err) {
				return
			}
			res := Res[*memorial.Memorial, any]{
				Data: m,
			}
			if sjson.HttpWrite(w, res) {
				return
			}
		})
	})

}
