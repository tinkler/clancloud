package router

import (
	"github.com/go-chi/chi/v5"
	"github.com/tinkler/clancloud/pkg/middleware"
)

func GetGlobalMiddlewares(m *chi.Mux) {
	m.Use(middleware.Cors)
}
