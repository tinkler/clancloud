//go:build wireinject
// +build wireinject

package router

import (
	"net/http"

	"github.com/google/wire"
	"github.com/tinkler/mqttadmin/pkg/conf"
)

var (
	confSet = wire.NewSet(conf.NewGormConfig, conf.NewConf)
)

// NewServer 新建服务
func NewServer() (*http.Server, error) {
	wire.Build(confSet, NewRouter)
	return nil, nil
}
