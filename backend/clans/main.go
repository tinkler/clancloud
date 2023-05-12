package main

import (
	_ "github.com/joho/godotenv/autoload"
	"github.com/tinkler/clancloud/clans/internal/router"
)

func main() {
	s, err := router.InitRouter()
	if err != nil {
		panic(err)
	}
	if err := s.ListenAndServe(); err != nil {
		panic(err)
	}
}
