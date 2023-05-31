package clan

import (
	"context"
	"net/http"

	"github.com/tinkler/mqttadmin/pkg/logger"
	"github.com/tinkler/mqttadmin/pkg/status"
)

func (m *User) CanEditMember(ctx context.Context, memberID int64) bool {
	if m.MemberID == 0 {
		return false
	}
	if m.MemberID == memberID {
		return true
	}
	member := &Member{ID: m.MemberID}
	err := member.GetByID(ctx, 3, -1)
	if err != nil {
		logger.Error(err)
		return false
	}
	for father := member.Father; father != nil; father = father.Father {
		if father.ID == memberID {
			return true
		}
	}
	return member.HasChildrenID(memberID)
}

func (m *Member) HasChildrenID(id int64) bool {
	for _, child := range m.Children {
		if child.ID == id {
			return true
		}
		if len(child.Children) > 0 {
			if child.HasChildrenID(id) {
				return true
			}
		}
	}
	return false
}

func (m *Member) validate() error {
	if m.Surname == "" {
		return status.NewCnf(http.StatusOK, "%d's surname is empty", "%d的姓氏为空", m.ID)
	}
	if m.Name == "" {
		return status.NewCnf(http.StatusOK, "%d's name is empty", "%d的名字为空", m.ID)
	}
	if m.Nationality == "" {
		return status.NewCnf(http.StatusOK, "%d's nationality is empty", "%d的名族为空", m.ID)
	}
	return nil
}
