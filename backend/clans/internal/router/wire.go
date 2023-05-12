//go:build wireinject
// +build wireinject

package router

import (
	"github.com/google/wire"
	"github.com/tinkler/mqttadmin/pkg/conf"
	"github.com/tinkler/mqttadmin/pkg/db"
	"net/http"
)

var (
	confSet = wire.NewSet(conf.NewGormConfig, conf.NewConf)
	dbSet   = wire.NewSet(db.NewDB)
)

// InitRouter 初始化路由
func InitRouter() (*http.Server, error) {
	wire.Build(confSet, dbSet, NewRouter)
	return nil, nil
}
