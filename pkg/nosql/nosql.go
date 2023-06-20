package nosql

import (
	"context"
	"os"
	"sync"

	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

var (
	clientInstance *mongo.Client
	clientOnce     sync.Once
)

func DB() *mongo.Client {
	clientOnce.Do(func() {
		clientOptions := options.Client().ApplyURI(os.Getenv("MONGO_URI"))
		var err error
		clientInstance, err = mongo.Connect(context.Background(), clientOptions)
		if err != nil {
			panic(err)
		}

		err = clientInstance.Ping(context.Background(), nil)
		if err != nil {
			panic(err)
		}
	})
	return clientInstance
}

func Close() error {
	if clientInstance != nil {
		return clientInstance.Disconnect(context.Background())
	}
	return nil
}
