package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	_ "github.com/joho/godotenv/autoload"
	"github.com/tinkler/clancloud/backend/memorial/pkg/router"
	"github.com/tinkler/clancloud/pkg/cauth"
	"github.com/tinkler/mqttadmin/pkg/acl"
	"github.com/tinkler/mqttadmin/pkg/logger"
	"github.com/tinkler/mqttadmin/pkg/qm"
	"github.com/tinkler/mqttadmin/pkg/rabbitmq"
)

func main() {
	logger.ConsoleLevel = logger.LL_DEBUG

	server, err := router.NewServer()
	if err != nil {
		panic(err)
	}

	sig := make(chan os.Signal, 1)
	signal.Notify(sig, os.Interrupt, syscall.SIGTERM, syscall.SIGINT, syscall.SIGHUP, syscall.SIGQUIT)

	serverCtx, serverStopCtx := context.WithCancel(context.Background())

	aclm := acl.Aclm()
	// auth server
	err = cauth.Run()
	if err != nil {
		panic(err)
	}

	go func() {
		<-sig

		// Shutdown signal with grace period of 30 seconds
		shutdownCtx, _ := context.WithTimeout(serverCtx, 30*time.Second)

		go func() {
			<-shutdownCtx.Done()
			if shutdownCtx.Err() == context.DeadlineExceeded {
				log.Fatal("graceful shutdown timed out.. forcing exit.")
			}
		}()

		// Trigger graceful shutdown
		err := server.Shutdown(shutdownCtx)
		if err != nil {
			log.Fatal(err)
		}
		aclm.Close()
		qm.Qm().Driver.Close()
		rabbitmq.AmqpClose()
		if err := cauth.Close(); err != nil {
			logger.Error(err)
		}
		serverStopCtx()
	}()

	logger.Info("启动服务")
	err = server.ListenAndServe()
	if err != nil && err != http.ErrServerClosed {
		log.Fatal(err)
	}
	<-serverCtx.Done()
}
