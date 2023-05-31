package clan

import (
	"context"

	"github.com/tinkler/mqttadmin/pkg/acl"
	"github.com/tinkler/mqttadmin/pkg/db"
)

var (
	contextUser contextKey = "user"
)

func (m *User) Create() error {
	err := db.DB().Create(m).Error
	if err != nil {
		return err
	}
	return acl.AddRole(m.ID, RoleClansLevel5)
}

func GetUser(ctx context.Context) (*User, error) {

	u := &User{}
	err := u.Load(ctx)
	if err != nil {
		return nil, err
	}
	return u, nil
}
