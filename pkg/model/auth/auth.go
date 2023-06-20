package auth

import (
	"errors"
	"io"

	"github.com/tinkler/mqttadmin/pkg/db"
	"github.com/tinkler/mqttadmin/pkg/gs"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// Clan user
type User struct {
	// uuidv4
	ID        string
	Username  string
	Nickname  string
	AvatarUrl string
	MemberID  int64
}

func (m *User) TableName() string {
	return "v3.user"
}

type UserManager struct {
	Ver string
}

func (m *UserManager) AllUser(stream gs.Stream[*User]) error {
	var data []*User
	if err := db.DB().Find(&data).Error; err != nil {
		return err
	}
	for _, d := range data {
		err := stream.Send(d)
		if errors.Is(io.EOF, err) || status.Code(err) == codes.Canceled {
			return nil
		}
		if err != nil {
			return err
		}
	}
	return nil
}
