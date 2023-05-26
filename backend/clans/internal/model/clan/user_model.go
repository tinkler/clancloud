package clan

import (
	"github.com/tinkler/mqttadmin/pkg/acl"
	"github.com/tinkler/mqttadmin/pkg/db"
)

func (m *User) Create() error {
	err := db.DB().Create(m).Error
	if err != nil {
		return err
	}
	return acl.AddRole(m.ID, RoleClansLevel5)
}
