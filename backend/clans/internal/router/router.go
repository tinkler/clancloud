package router

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/tinkler/clancloud/backend/clans/internal/route"
	"github.com/tinkler/mqttadmin/pkg/acl"
	"github.com/tinkler/mqttadmin/pkg/conf"
	"github.com/tinkler/mqttadmin/pkg/db"
	"github.com/tinkler/mqttadmin/pkg/logger"
)

func GetRoutes(m *chi.Mux) {
	m.Route("/clans", func(r chi.Router) {
		r.Use(acl.WrapAuth(acl.AuthConfig{}))
		route.RoutesClan(r)
		route.RoutesClanExtra(r)
	})
}

func NewRouter(conf *conf.Conf) (*http.Server, error) {
	r := chi.NewRouter()
	r.Use(logger.ChiLogger(func(formatter *logger.LogFormatter) {
		formatter.AddRouteInfo(route.GetPathDebugLine("/clans"))
	}))
	r.Use(db.WrapGorm())
	GetGlobalMiddlewares(r)
	GetRoutes(r)
	r.Handle("/static/*", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))

	server := http.Server{
		Addr:    conf.Server.Addr,
		Handler: r,
		// ReadTimeout:  conf.Server.ReadTimeout,
		// WriteTimeout: conf.Server.WriteTimeout,
		// IdleTimeout:  conf.Server.IdleTimeout,
	}

	return &server, nil
}
