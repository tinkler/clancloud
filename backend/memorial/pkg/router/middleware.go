package router

import (
	"github.com/go-chi/chi/v5"
	"github.com/tinkler/clancloud/backend/memorial/internal/middleware"
)

func GetGlobalMiddlewares(m *chi.Mux) {
	m.Use(middleware.Cors)
}
