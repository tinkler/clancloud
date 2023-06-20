package cauth

import (
	"os"
	"sync"
)

type conf struct {
	AuthServerAddress string
}

var (
	confInst *conf
	confOnce sync.Once
)

func Conf() *conf {
	confOnce.Do(func() {
		authServerAddress := os.Getenv("AUTH_SERVER")
		if authServerAddress == "" {
			panic("AUTH_SERVER not found. please check your environment or .env file")
		}
		confInst = &conf{
			AuthServerAddress: authServerAddress,
		}
	})

	return confInst
}
