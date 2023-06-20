package sauth

import (
	"context"
	"time"

	"github.com/streadway/amqp"
	"github.com/tinkler/clancloud/internal/auth_const"
	"github.com/tinkler/mqttadmin/pkg/logger"
	"github.com/tinkler/mqttadmin/pkg/rabbitmq"
)

type manager struct {
	ctx          context.Context
	closeFunc    context.CancelFunc
	ch           *amqp.Channel
	updateSignal chan struct{}
}

var defaultServerManager = &manager{
	updateSignal: make(chan struct{}),
}

func Run() error {
	defaultServerManager.ctx, defaultServerManager.closeFunc = context.WithCancel(context.Background())
	listenUpdateAndNotify()
	return nil
}

func listenUpdateAndNotify() {
	ch, err := rabbitmq.AmqpChannel()
	if err != nil {
		panic(err)
	}
	defaultServerManager.ch = ch
	// exchangeName := "my_exchange"
	// routingKey := "my_key"

	queue, err := ch.QueueDeclare(
		auth_const.AuthCacheQueue,
		false,
		false,
		false,
		false,
		nil,
	)
	if err != nil {
		panic(err)
	}
	// if err := ch.QueueBind(auth_const.AuthCacheQueue, routingKey, exchangeName, false, nil); err != nil {
	// 	panic(err)
	// }

	p := amqp.Publishing{
		ContentType: "text/plain",
		Body:        []byte{},
	}

	closed := make(chan struct{})
	go func() {
		for {
			ec := defaultServerManager.ch.NotifyClose(make(chan *amqp.Error))
			if ec == nil {
				time.Sleep(rabbitmq.RetryDuration)
				continue
			}
			e := <-ec
			if e != nil {
				logger.Error(e)
			}
			close(closed)
			time.Sleep(rabbitmq.RetryDuration)
			listenUpdateAndNotify()
			return
		}
	}()

	go func() {
		for {
			select {
			case _, ok := <-defaultServerManager.updateSignal:
				if ok {
					err := ch.Publish(
						"",
						queue.Name,
						false,
						false,
						p,
					)
					if err != nil {
						logger.Error(err)
					}
				}
			case <-defaultServerManager.ctx.Done():
				return
			case <-closed:
				return
			}
		}
	}()
}

func Notification() {
	if defaultServerManager.ctx != nil && defaultServerManager.ctx.Err() == nil {
		defaultServerManager.updateSignal <- struct{}{}
	}
}

func Close() error {
	if defaultServerManager.ctx == nil {
		return nil
	}
	close(defaultServerManager.updateSignal)
	defaultServerManager.closeFunc()
	if err := defaultServerManager.ch.Close(); err != nil {
		return err
	}
	return nil
}
