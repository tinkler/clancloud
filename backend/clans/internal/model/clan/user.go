package clan

import (
	"context"
	"errors"

	"github.com/tinkler/mqttadmin/pkg/acl"
	"github.com/tinkler/mqttadmin/pkg/db"
	"github.com/tinkler/mqttadmin/pkg/status"
	"gorm.io/gorm"
)

type User struct {
	ID        string
	Username  string
	Nickname  string
	Sex       int
	AvatarUrl string
	MemberID  int64
	Roles     []string `gorm:"-"`
}

func (m *User) TableName() string {
	return "v3.user"
}

func (m *User) Save(ctx context.Context) error {
	if m.ID == "" {
		m.ID = acl.GetUserID(ctx)
	}
	se := db.DB().First(&User{ID: m.ID})
	if se.Error != nil {
		if errors.Is(se.Error, gorm.ErrRecordNotFound) {
			return m.Create()
		}
		return se.Error
	}
	se = db.DB().Model(m)
	if m.MemberID == 0 {
		se.Select("member_id")
	}
	if err := se.Updates(m).Error; err != nil {
		return err
	}

	if m.MemberID > 0 {
		acl.AddRole(m.ID, RoleClansLevel4)
	} else {
		acl.RemoveRole(m.ID, RoleClansLevel4)
	}
	return nil
}

func (m *User) Load(ctx context.Context) error {
	if acl.HasRole(ctx, acl.RoleAdmin) {
		if m.ID == "" {
			m.ID = acl.GetUserID(ctx)
			if m.ID == "" {
				return status.StatusForbidden()
			}
			m.Roles = acl.GetAllRoles(ctx)
		}
		if err := db.DB().First(m).Error; err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return m.Create()
			}
			return err
		}
		if err := db.DB().First(m).Error; err != nil {
			return err
		}
		return nil
	}
	if acl.HasRole(ctx, acl.RoleUser) {
		m.ID = acl.GetUserID(ctx)
		if m.ID == "" {
			return status.StatusForbidden()
		}
		m.Roles = acl.GetAllRoles(ctx)
		if err := db.DB().First(m).Error; err != nil {
			if errors.Is(err, gorm.ErrRecordNotFound) {
				return m.Create()
			}
			return err
		}
		if err := db.DB().First(m).Error; err != nil {
			return err
		}
		return nil
	}
	return status.StatusForbidden()
}
