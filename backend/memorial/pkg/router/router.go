package router

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
	"github.com/tinkler/clancloud/backend/memorial/internal/route"
	"github.com/tinkler/mqttadmin/pkg/acl"
	"github.com/tinkler/mqttadmin/pkg/conf"
	"github.com/tinkler/mqttadmin/pkg/logger"
)

func GetRoutes(m *chi.Mux) {
	m.Route("/memorial", func(r chi.Router) {
		r.Use(acl.WrapAuth(acl.AuthConfig{}))
		route.RoutesMemorial(r)
		route.RoutesMemorialExtra(r)
	})
}

func NewRouterServer(conf *conf.Conf) (*http.Server, error) {
	r := chi.NewRouter()
	r.Use(middleware.Recoverer)
	r.Use(logger.ChiLogger(func(formatter *logger.LogFormatter) {
		formatter.AddRouteInfo(route.GetPathDebugLine("/memorial"))
	}))
	GetGlobalMiddlewares(r)
	GetRoutes(r)
	r.Handle("/static/*", http.StripPrefix("/static/", http.FileServer(http.Dir("static"))))
	server := http.Server{
		Addr:         conf.Server.Addr,
		Handler:      r,
		ReadTimeout:  conf.Server.ReadTimeout,
		WriteTimeout: conf.Server.WriteTimeout,
		IdleTimeout:  conf.Server.IdleTimeout,
	}
	return &server, nil
}
