package clan

import (
	"context"
	"strings"

	"github.com/tinkler/mqttadmin/pkg/db"
	"github.com/tinkler/mqttadmin/pkg/jsonz/sjson"
)

type Member struct {
	ID                    int64
	Name                  string
	Surname               string
	Nationality           string
	Sex                   int
	BirthRecordsPrefix    string
	BirthRecords          string
	BirthPlace            string
	Qualifications        string
	Contribution          int
	Rank                  int
	Introduction          string
	RecognizaedGeneration int
	IsMarray              int
	IsAlive               int
	ProfilePicture        string
	Spouse                *Member   `gorm:"-"`
	Spouses               []*Member `gorm:"-"`
	Father                *Member   `gorm:"-"`
	Children              []*Member `gorm:"-"`
}

type memberData struct {
	ID       int64
	Surname  string
	Name     string
	Sex      int
	Rank     int
	TagID    int64
	Father   string
	Children string
	Spouses  string
}

func (m *Member) GetByID(ctx context.Context, fdep int, cdep int) error {
	var data []*memberData
	se := db.GetDB(ctx).Raw("select * from v1.func_get_clan(?, ?, ?)", m.ID, fdep, cdep).Scan(&data)
	if se.Error != nil {
		return se.Error
	}
	if len(data) == 0 {
		return nil
	}
	m.ID = data[0].ID
	m.Surname = data[0].Surname
	m.Name = data[0].Name
	m.Sex = data[0].Sex
	m.Rank = data[0].Rank
	if data[0].Father != "" {
		m.Father = &Member{}
		err := sjson.Unmarshal([]byte(data[0].Father), m.Father)
		if err != nil {
			return err
		}
	}
	if data[0].Children != "" {
		err := sjson.Unmarshal([]byte(data[0].Children), &m.Children)
		if err != nil {
			return err
		}
	}
	if data[0].Spouses != "" {
		err := sjson.Unmarshal([]byte(data[0].Spouses), &m.Spouses)
		if err != nil {
			return err
		}
	}

	return nil
}

func (m *Member) SearchMember(ctx context.Context, match string) ([]*Member, error) {
	if match == "" {
		return nil, nil
	}
	matches := strings.Split(match, " ")
	if len(matches) > 1 {
		var data []*Member
		se := db.GetDB(ctx).Raw("select * from v1.member as my left join v1.generation_relationship as rel on my.id = rel.id and rel.member_status = my.status - 1 left join v1.member as fa on rel.member_id = fa.id where my.name like ? and fa.name like ?", "%"+matches[0]+"%", "%"+matches[1]+"%").Scan(&data)
		if se.Error != nil {
			return nil, se.Error
		}
		return data, nil
	} else {
		var data []*Member
		se := db.GetDB(ctx).Raw("select * from v1.member where name like ? limit 10", "%"+matches[0]+"%").Scan(&data)
		if se.Error != nil {
			return nil, se.Error
		}
		return data, nil
	}
}
