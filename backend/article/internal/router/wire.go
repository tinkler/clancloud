//go:build wireinject
// +build wireinject

package router

import (
	"net/http"

	"github.com/google/wire"
	"github.com/tinkler/mqttadmin/pkg/conf"
)

var (
	confSet = wire.NewSet(conf.NewConf)
)

func NewServer() (*http.Server, error) {
	wire.Build(confSet, NewRouterServer)
	return nil, nil
}
