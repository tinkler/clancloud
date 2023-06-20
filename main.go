package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"strings"
	"syscall"
	"time"

	_ "github.com/joho/godotenv/autoload"
	auth_v1 "github.com/tinkler/clancloud/auth/v1"
	"github.com/tinkler/clancloud/internal/sauth"
	"github.com/tinkler/clancloud/pkg/gsrv"
	"github.com/tinkler/mqttadmin/pkg/conf"
	"github.com/tinkler/mqttadmin/pkg/logger"
	"github.com/tinkler/mqttadmin/pkg/rabbitmq"
	"golang.org/x/net/http2"
	"golang.org/x/net/http2/h2c"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials/insecure"
)

func main() {
	logger.ConsoleLevel = logger.LL_DEBUG

	err := sauth.Run()
	if err != nil {
		panic(err)
	}

	cnf := conf.NewConf()
	s := grpc.NewServer(grpc.Creds(insecure.NewCredentials()))
	auth_v1.RegisterAuthGsrvServer(s, gsrv.NewAuthGsrv())
	staticServer := http.FileServer(http.Dir("static"))
	muxHanlder := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.ProtoMajor == 2 && strings.HasPrefix(r.Header.Get("Content-Type"), "application/grpc") {
			s.ServeHTTP(w, r)
			return
		}
		if p := strings.TrimPrefix(r.URL.Path, "/assets"); len(p) < len(r.URL.Path) {
			sps := strings.Index(p[1:], "/")
			r2 := new(http.Request)
			*r2 = *r
			*r2.URL = *r.URL
			r2.URL.Path = p[sps+1:]
			staticServer.ServeHTTP(w, r2)
			return
		}
	})

	sig := make(chan os.Signal, 1)
	signal.Notify(sig, os.Interrupt, syscall.SIGTERM, syscall.SIGINT, syscall.SIGHUP, syscall.SIGQUIT)
	go func() {
		if err := http.ListenAndServe(cnf.Server.Addr, h2c.NewHandler(muxHanlder, &http2.Server{})); err != nil {
			panic(err)
		}
	}()

	checked := make(chan struct{})
	go func() {
		timeout := time.NewTimer(time.Second * 10)
		for {
			select {
			case <-timeout.C:
				panic("server isn't started after 10 seconds")
			default:
				status := s.GetServiceInfo()
				if status == nil {
					time.Sleep(time.Millisecond * 100)
				} else {
					sauth.Notification()
					close(checked)
					return
				}
			}
		}
	}()

	<-checked

	logger.Title("Start auth server on %s", cnf.Server.Addr)
	serverCtx, serverStopCtx := context.WithCancel(context.Background())

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

		s.GracefulStop()
		if err := sauth.Close(); err != nil {
			logger.Error(err)
		}
		rabbitmq.AmqpClose()
		serverStopCtx()
	}()

	<-serverCtx.Done()

}
