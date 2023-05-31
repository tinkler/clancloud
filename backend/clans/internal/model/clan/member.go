package clan

import (
	"context"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"github.com/google/uuid"
	"github.com/tinkler/mqttadmin/pkg/db"
	"github.com/tinkler/mqttadmin/pkg/jsonz/sjson"
	"github.com/tinkler/mqttadmin/pkg/logger"
	"github.com/tinkler/mqttadmin/pkg/status"
	"gorm.io/gorm"
)

type Member struct {
	ID                   int64 `gorm:"primaryKey"`
	Name                 string
	Surname              string
	Nationality          string
	TagID                int
	Sex                  int
	BirthRecordsPrefix   string
	BirthRecords         string
	BirthPlace           string
	Qualifications       string
	Contribution         int
	Rank                 int
	Introduction         string
	RecognizedGeneration int
	IsMarry              int
	IsAlive              int
	MemberProfile        *MemberProfile `gorm:"foreignKey:ID;references:ID"`
	Spouse               *Member        `gorm:"-"`
	Spouses              []*Member      `gorm:"-"`
	Father               *Member        `gorm:"-"`
	Children             []*Member      `gorm:"-"`
}

func (m *Member) TableName() string {
	return "v1.member"
}

type memberData struct {
	ID       int64
	Name     string
	Surname  string
	Sex      int
	Rank     int
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
		se := db.GetDB(ctx).Raw("select * from v1.member as my left join v1.member_generation_relationship as rel on my.id = child_id left join v1.member as fa on main_id = fa.id where my.name like ? and fa.name like ?", "%"+matches[0]+"%", "%"+matches[1]+"%").Scan(&data)
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

func (m *Member) Load(ctx context.Context) error {
	if m.ID == 0 {
		return status.NewCn(http.StatusOK, "id is empty", "id为空")
	}

	if !HasRoleLevel4(ctx) {
		return status.StatusForbidden()
	}

	se := db.GetDB(ctx).Where("id = ?", m.ID).Find(m)
	if se.Error != nil {
		return se.Error
	}
	return nil
}

// 更新所有不为空数据,请注意调用Load方法后更新值再调用此方法
func (m *Member) Update(ctx context.Context) error {
	if m.ID == 0 {
		return status.NewCn(http.StatusOK, "id is empty", "id为空")
	}

	if !HasRoleLevel4(ctx) {
		return status.StatusForbidden()
	}

	u, err := GetUser(ctx)
	if err != nil {
		return err
	}

	if !u.CanEditMember(ctx, m.ID) {
		return status.StatusForbidden()
	}

	se := db.GetDB(ctx).Model(m).Omit("RecognizedGeneration", "MemberProfile").Updates(m)
	if se.Error != nil {
		return se.Error
	}
	return nil
}

// @ignore(*)
func (m *Member) UploadProfilePicture(ctx context.Context, file multipart.File, fileName string) error {
	if !HasRoleLevel4(ctx) {
		return status.StatusForbidden()
	}

	ext := filepath.Ext(fileName)
	if ext != ".jpg" && ext != ".png" && ext != ".jpeg" && ext != ".gif" {
		return status.NewCn(http.StatusOK, "only jpg,jpeg,gif and png are supported", "只支持jpg、png、jpeg、git格式的图片")
	}

	filePath := "member/" + uuid.New().String() + ext
	staticPath := "static/" + filePath
	dstFile, err := os.Create(staticPath)
	if err != nil {
		logger.Error(err)
		return err
	}

	_, err = io.Copy(dstFile, file)
	if err != nil {
		logger.Error(err)
		dstFile.Close()
		return err
	}
	dstFile.Close()
	se := db.DB().Model(&MemberProfile{}).Where("id = ?", m.ID).Update("pic_path", filePath)
	if se.Error != nil {
		logger.Error(se.Error)
		err := os.Remove(staticPath)
		if !os.IsNotExist(err) {
			logger.Error(err)
		}
		return se.Error
	}
	if m.MemberProfile == nil {
		m.MemberProfile = &MemberProfile{}
	}
	m.MemberProfile.PicPath = filePath

	return nil
}

// 新增子女
// 子女信息未录(主键空),将验证信息合法性并录入
// 子女信息已录(主键不空),以数据库查询结果为准
// 兄弟姐妹排序须自行计算,可通过UpdateRank单独更新
func (m *Member) AddChild(ctx context.Context, child *Member) error {
	if m.ID == 0 {
		return status.NewCn(http.StatusOK, "id is empty", "id为空")
	}

	u, err := GetUser(ctx)
	if err != nil {
		return err
	}

	if !HasRoleLevel4(ctx) {
		return status.StatusForbidden()
	}

	if !u.CanEditMember(ctx, m.ID) {
		return status.StatusForbidden()
	}
	child.Surname = m.Surname

	se := db.DB().Begin()
	defer se.Rollback()
	if child.ID != 0 {
		if err := se.First(&Member{ID: child.ID}).Error; err != nil {
			if err == gorm.ErrRecordNotFound {
				return status.NewCn(http.StatusOK, "child not found", "子女不存在")
			}
			return err
		}
	} else {
		if err := child.validate(); err != nil {
			return err
		}
		child.RecognizedGeneration = m.RecognizedGeneration + 1
		if child.Rank == 0 {
			child.Rank = len(m.Children) + 1
		}
		if err := se.Omit("MemberProfile").Create(child).Error; err != nil {
			return err
		}
		if child.ID == 0 {
			return status.StatusInternalServer()
		}
	}

	mgrCount := int64(0)
	err = se.Model(&MemberGenerationRelationship{}).Where("main_id = ? and child_id = ?", m.ID, child.ID).Count(&mgrCount).Error
	if err != nil {
		return err
	}

	if mgrCount > 0 {
		return nil
	}

	mgr := &MemberGenerationRelationship{
		MainID:                    m.ID,
		ChildID:                   child.ID,
		ChildRecognizedGeneration: m.RecognizedGeneration + 1,
	}
	err = se.Create(mgr).Error
	if err != nil {
		return err
	}

	se.Commit()
	if se.Error != nil {
		return se.Error
	}
	m.Children = append(m.Children, child)
	return nil
}

// 将直接删除并删除联系
// @feature 子女排序须自行修正
// 子女将变成独立族谱
// 不包括删除配偶
// 删除前请进行判断作友好交互
func (m *Member) Delete(ctx context.Context) error {
	if m.ID == 0 {
		return status.NewCn(http.StatusOK, "id is empty", "id为空")
	}
	se := db.DB().Begin()
	defer se.Rollback()

	u, err := GetUser(ctx)
	if err != nil {
		return err
	}

	if !HasRoleLevel4(ctx) {
		return status.StatusForbidden()
	}

	if !u.CanEditMember(ctx, m.ID) {
		return status.StatusForbidden()
	}

	err = m.Load(ctx)
	if err != nil {
		return err
	}

	err = se.Where("main_id = ? or child_id = ?", m.ID, m.ID).Delete(&MemberGenerationRelationship{}).Error
	if err != nil {
		return err
	}

	// TODO: 删除头像
	// if m.MemberProfile != nil {

	// }

	err = se.Where("id = ?", m.ID).Select("MemberProfile").Delete(&Member{}).Error
	if err != nil {
		return err
	}

	se.Commit()
	if se.Error != nil {
		return se.Error
	}

	m.ID = 0

	return nil
}
