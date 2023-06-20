package memorial

import (
	"context"
	"io"
	"mime/multipart"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/tinkler/clancloud/backend/memorial/pkg/const/dbc"
	"github.com/tinkler/clancloud/pkg/acl"
	"github.com/tinkler/clancloud/pkg/cauth"
	"github.com/tinkler/clancloud/pkg/nosql"
	"github.com/tinkler/mqttadmin/pkg/logger"
	"github.com/tinkler/mqttadmin/pkg/status"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
)

const (
	memorialCollection = "memorial"
)

type Memorial struct {
	ID      string `json:"_id" bson:"_id"`
	Name    string `json:"name" bson:"name"`
	PicPath string `json:"pic_path" bson:"pic_path"`
	// time 2006-01-02 15:04:05
	CreateByUserID string         `json:"create_by_user_id" bson:"create_by_user_id"`
	Commemorations []*Commemorate `json:"commemorations" bson:"commemorations"`
	// RFC3339
	CreateAt string `json:"create_at" bson:"create_at"`
}

func (m *Memorial) Create(ctx context.Context) error {

	m.Name = strings.TrimSpace(m.Name)
	if m.Name == "" {
		return status.OkCn("name is empty", "名字不能为空")
	}

	memorialCollection := nosql.DB().Database(dbc.ServieDB).Collection(memorialCollection)

	m.CreateByUserID = acl.GetUserID(ctx)
	m.CreateAt = time.Now().Format(time.RFC3339)
	id := primitive.NewObjectID()
	_, err := memorialCollection.InsertOne(ctx, bson.M{"_id": id, "name": m.Name, "create_by_user_id": m.CreateByUserID, "create_at": m.CreateAt, "commemorations": []bson.M{}})
	if err != nil {
		return status.StatusInternalServer(err)
	}
	m.ID = id.Hex()
	return nil
}

// @ignore(*)
func (m *Memorial) UploadPicture(ctx context.Context, file multipart.File, fileName string) error {
	if !acl.HasRoleLevel4(ctx) {
		return status.StatusForbidden()
	}
	ext := filepath.Ext(fileName)
	if ext != ".jpg" && ext != ".png" && ext != ".jpeg" && ext != ".gif" {
		return status.NewCn(http.StatusOK, "only jpg,jpeg,gif and png are supported", "只支持jpg、png、jpeg、git格式的图片")
	}

	filePath := "memorial/" + uuid.New().String() + ext
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

	memorialCC := nosql.DB().Database(dbc.ServieDB).Collection(memorialCollection)
	update := bson.M{"$set": bson.M{"pic_path": filePath}}
	id, _ := primitive.ObjectIDFromHex(m.ID)
	_, err = memorialCC.UpdateOne(ctx, bson.M{"_id": id}, update)
	if err != nil {
		return status.StatusInternalServer(err)
	}
	m.PicPath = filePath
	return nil
}

func (m *Memorial) Update(ctx context.Context) error {
	if m.ID == "" {
		return status.NewCn(http.StatusOK, "id is empty", "ID为空")
	}
	if !acl.HasRoleLevel4(ctx) {
		return status.StatusForbidden()
	}
	memorialCC := nosql.DB().Database(dbc.ServieDB).Collection(memorialCollection)
	update := bson.M{"$set": bson.M{"name": m.Name}}
	id, _ := primitive.ObjectIDFromHex(m.ID)
	_, err := memorialCC.UpdateOne(ctx, bson.M{"_id": id}, update)
	if err != nil {
		return status.StatusInternalServer(err)
	}
	return nil
}

func (m *Memorial) Delete(ctx context.Context) error {
	if m.ID == "" {
		return status.NewCn(http.StatusOK, "id is empty", "ID为空")
	}
	if !acl.HasRoleLevel4(ctx) {
		return status.StatusForbidden()
	}
	var foundMemorial Memorial
	memorialCC := nosql.DB().Database(dbc.ServieDB).Collection(memorialCollection)
	id, _ := primitive.ObjectIDFromHex(m.ID)
	err := memorialCC.FindOne(ctx, bson.M{"_id": id}).Decode(&foundMemorial)
	if err != nil {
		return status.StatusInternalServer(err)
	}
	if foundMemorial.CreateByUserID == "" {
		return status.NewCn(http.StatusOK, "memorial not found", "没有该纪念堂数据")
	}

	if foundMemorial.CreateByUserID != acl.GetUserID(ctx) && !acl.HasRoleLevel1(ctx) {
		return status.StatusForbidden()
	}

	_, err = memorialCC.DeleteOne(ctx, bson.M{"_id": foundMemorial.ID})
	if err != nil {
		return status.StatusInternalServer(err)
	}

	return nil
}

func (m *Memorial) Commemorate(ctx context.Context, commemorate *Commemorate) error {
	if m.ID == "" {
		return status.NewCn(http.StatusOK, "id is empty", "ID为空")
	}
	memorialCC := nosql.DB().Database(dbc.ServieDB).Collection(memorialCollection)
	newsId, _ := primitive.ObjectIDFromHex(m.ID)
	commemorate.CreateAt = time.Now().Format(time.RFC3339)
	commemorate.PersonID = acl.GetUserID(ctx)
	cm := bson.M{
		"_id":       primitive.NewObjectID(),
		"event":     commemorate.Event,
		"person_id": commemorate.PersonID,
		"create_at": commemorate.CreateAt,
	}
	filter := bson.M{"_id": newsId}
	update := bson.M{"$push": bson.M{"commemorations": cm}}
	result, err := memorialCC.UpdateOne(ctx, filter, update)
	if err != nil {
		return status.StatusInternalServer(err)
	}
	if result.MatchedCount == 0 {
		logger.Error("commemorate no matched data")
	}
	if result.ModifiedCount == 0 {
		logger.Error("commemorate no modified data")
	}
	return nil
}

func (m *Memorial) LatestCommemorations(ctx context.Context) ([]*Commemorate, error) {
	if m.ID == "" {
		return nil, status.NewCn(http.StatusOK, "id is empty", "ID为空")
	}
	memorialCC := nosql.DB().Database(dbc.ServieDB).Collection(memorialCollection)
	memorialID, _ := primitive.ObjectIDFromHex(m.ID)
	filter := bson.M{"_id": memorialID}
	pipeline := []bson.M{
		{
			"$match": filter,
		},
		{
			"$project": bson.M{
				"commemorations": bson.M{
					"$slice": []interface{}{
						"$commemorations", -10, 10,
					},
				},
			},
		},
		{
			"$unwind": "$commemorations",
		},
		{
			"$sort": bson.M{
				"commemorations.create_at": -1,
			},
		},
		{
			"$group": bson.M{
				"_id":            "$_id",
				"commemorations": bson.M{"$push": "$commemorations"},
			},
		},
	}
	cur, err := memorialCC.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, status.StatusInternalServer(err)
	}
	defer cur.Close(ctx)
	result := new(Memorial)
	if cur.Next(ctx) {
		err := cur.Decode(result)
		if err != nil {
			return nil, status.StatusInternalServer(err)
		}
	}

	for _, c := range result.Commemorations {
		c.PersonName = cauth.GetNicknameByID(c.PersonID)
		if createAt, err := time.Parse(time.RFC3339, c.CreateAt); err == nil {
			c.CreateAt = createAt.Format(time.DateTime)
		} else {
			logger.Warn(err)
		}
	}
	return result.Commemorations, nil
}
