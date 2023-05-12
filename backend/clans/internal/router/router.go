package router

import (
	"net/http"

	"github.com/go-chi/chi/middleware"
	"github.com/go-chi/chi/v5"
	"github.com/tinkler/clancloud/clans/internal/route"
	"github.com/tinkler/mqttadmin/pkg/conf"
	"github.com/tinkler/mqttadmin/pkg/db"
	mqttadmin "github.com/tinkler/mqttadmin/pkg/route"
	"gorm.io/gorm"
)

func GetRoutes(m *chi.Mux) {
	route.RoutesClan(m)
	mqttadmin.RoutesUser(m)
}

func NewRouter(conf *conf.Conf, d *gorm.DB) (*http.Server, error) {
	r := chi.NewRouter()
	r.Use(middleware.Logger)
	r.Use(db.WrapGorm(d))
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
