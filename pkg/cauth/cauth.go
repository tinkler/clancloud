/*
caching auth information
*/
package cauth

import (
	"context"
	"errors"
	"io"
	"time"

	"github.com/streadway/amqp"
	auth_v1 "github.com/tinkler/clancloud/auth/v1"
	"github.com/tinkler/clancloud/internal/auth_const"
	"github.com/tinkler/clancloud/pkg/model/auth"
	mrz_v1 "github.com/tinkler/mqttadmin/mrz/v1"
	"github.com/tinkler/mqttadmin/pkg/logger"
	"github.com/tinkler/mqttadmin/pkg/rabbitmq"
	"google.golang.org/grpc"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/status"
)

type manager struct {
	ctx          context.Context
	closeFunc    context.CancelFunc
	update       chan struct{}
	updateSignal chan struct{}
	updateFunc   func()
	// user client
	client *userClient
	// rabbitmq channel
	ch *amqp.Channel
}

var defaultManager = &manager{
	update:       make(chan struct{}),
	updateSignal: make(chan struct{}),
	updateFunc:   refreshUserCache,
}

var defaultClient *userClient

type userClient struct {
	conn *grpc.ClientConn
	c    auth_v1.AuthGsrvClient
}

func newUserClient() *userClient {
	conn, err := grpc.Dial(Conf().AuthServerAddress, grpc.WithTransportCredentials(insecure.NewCredentials()))
	if err != nil {
		panic(err)
	}
	return &userClient{
		conn: conn,
		c:    auth_v1.NewAuthGsrvClient(conn),
	}
}

func (c *userClient) Close() error {
	return c.conn.Close()
}

// listen to update signal received from RabbitMQ
// only one signal will active in 10 seconds
func Run() error {
	defaultManager.ctx, defaultManager.closeFunc = context.WithCancel(context.Background())
	// listen and update
	go func() {
		for {
			select {
			case _, ok := <-defaultManager.update:
				if ok {
					logger.Info("Refresh user cache")
					defaultManager.updateFunc()
				}
			case <-defaultManager.ctx.Done():
				return
			}
		}
	}()
	// merge updateSignal to update
	go func() {
		for {
			if defaultManager.ctx.Err() != nil {
				return
			}
			_, ok := <-defaultManager.updateSignal
			if !ok {
				continue
			}
			timeout := time.NewTimer(10 * time.Second)
		MERGE:
			for {
				select {
				case <-timeout.C:
					defaultManager.update <- struct{}{}
					break MERGE
				case <-defaultManager.updateSignal:
				}
			}
		}
	}()
	// create user client
	// consume the user
	defaultClient = newUserClient()
	defaultManager.client = defaultClient
	listenUpdateQueue()
	// init
	refreshUserCache()
	return nil
}

func listenUpdateQueue() {
	var err error
	defaultManager.ch, err = rabbitmq.AmqpChannel()
	if err != nil {
		panic(err)
	}
	// exchangeName := "my_exchange"
	// routingKey := "my_key"
	queue, err := defaultManager.ch.QueueDeclare(
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
	// if err := defaultManager.ch.QueueBind(auth_const.AuthCacheQueue, routingKey, exchangeName, false, nil); err != nil {
	// 	panic(err)
	// }
	msc, err := defaultManager.ch.Consume(
		queue.Name,
		"",
		true,
		false,
		false,
		false,
		nil,
	)
	if err != nil {
		panic(err)
	}
	closed := make(chan struct{})
	go func() {
		for {
			ec := defaultManager.ch.NotifyClose(make(chan *amqp.Error))
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
			listenUpdateQueue()
			return
		}
	}()
	go func() {
		for {
			select {
			case _, ok := <-msc:
				if ok {
					defaultManager.updateSignal <- struct{}{}
				}
			case <-defaultManager.ctx.Done():
				return
			case <-closed:
				return
			}
		}
	}()
}

// It's safe to close twice
func Close() error {
	if defaultManager.ctx == nil {
		return errors.New("cauth not run")
	}
	if defaultManager.ctx.Err() != nil {
		return nil
	}
	defaultManager.closeFunc()
	if err := defaultManager.client.Close(); err != nil {
		return err
	}
	return nil
}

func refreshUserCache() {
	cacheUserMapID := make(map[string]*auth.User)

	stream, err := defaultClient.c.UserManagerAllUser(context.Background())
	if err != nil {
		logger.Error(err)
		return
	}
	for {
		anyRes, err := stream.Recv()
		if errors.Is(io.EOF, err) || status.Code(err) == codes.Canceled {
			setUserCache(cacheUserMapID)
			logger.Info("用户缓存数据更新%d", len(cacheUserMapID))
			if err := stream.CloseSend(); err != nil {
				logger.Error(err)
			}
			return
		}
		if err != nil {
			logger.Error(err)
			return
		}
		res := mrz_v1.ToTypedRes[*auth_v1.UserManager, *auth_v1.User](anyRes)
		cacheUserMapID[res.Resp.Id] = &auth.User{
			ID:        res.Resp.Id,
			Username:  res.Resp.Username,
			Nickname:  res.Resp.Nickname,
			AvatarUrl: res.Resp.AvatarUrl,
			MemberID:  res.Resp.MemberId,
		}
	}
}
