package article

import (
	"context"
	"errors"
	"net/http"
	"time"

	"github.com/tinkler/clancloud/pkg/acl"
	"github.com/tinkler/mqttadmin/pkg/status"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
)

type Article struct {
	ID             string `bson:"id"`
	Title          string `bson:"title"`
	Summary        string `bson:"summary"`
	Content        string `bson:"content"`
	CreateByUserID string `bson:"create_by_user_id"`
	TotalReadTimes int    `bson:"total_read_times"`
	CreateAt       string `bson:"create_at"`
}

type Articles struct{}

// it usually be cache in the frontend
// get the latest 4 articles
func (m *Articles) HomeList(ctx context.Context) ([]*Article, error) {
	findOption := options.Find()
	findOption.SetSort(bson.M{"create_at": -1})
	findOption.SetLimit(4)

	cc := GetNoDBArticleCC()
	cur, err := cc.Find(ctx, nil, findOption)
	if err != nil {
		return nil, status.StatusInternalServer(err)
	}
	defer cur.Close(context.Background())

	var data []*Article
	for cur.Next(ctx) {
		d := new(Article)
		err := cur.Decode(d)
		if err != nil {
			return nil, status.StatusInternalServer(err)
		}
		data = append(data, d)
	}
	return data, nil
}

// Create a new article when ID is empty
// Or else update title,summary,content
func (m *Article) Save(ctx context.Context) error {
	if m.Title == "" {
		return status.NewCn(http.StatusOK, "title is empty", "标题为空")
	}
	if m.Summary == "" {
		return status.NewCn(http.StatusOK, "summary is empty", "摘要为空")
	}
	if !acl.HasRoleLevel3(ctx) {
		return status.StatusForbidden()
	}

	cc := GetNoDBArticleCC()
	if m.ID == "" {
		id := primitive.NewObjectID()
		m.CreateByUserID = acl.GetUserID(ctx)
		m.CreateAt = time.Now().Format(time.RFC3339)
		_, err := cc.InsertOne(ctx, bson.M{
			"_id":               id,
			"title":             m.Title,
			"summary":           m.Summary,
			"content":           m.Content,
			"create_by_user_id": m.CreateByUserID,
			"create_at":         m.CreateAt,
		})
		if err != nil {
			return status.StatusInternalServer(err)
		}
		return nil
	}
	// m.ID != ""
	update := bson.M{"$set": bson.M{
		"title":   m.Title,
		"summary": m.Summary,
		"content": m.Content,
	}}
	id, err := primitive.ObjectIDFromHex(m.ID)
	if err != nil {
		return status.NewCn(http.StatusBadRequest, "id is invalid", "id非法")
	}

	findOne := new(Article)
	if err := cc.FindOne(ctx, bson.M{"_id": id}).Decode(findOne); err != nil {
		if errors.Is(mongo.ErrNoDocuments, err) {
			return status.NewCn(http.StatusBadRequest, "article is not exist", "文章不存在")
		}
		return status.StatusInternalServer(err)
	}

	if findOne.CreateByUserID != acl.GetUserID(ctx) &&
		!acl.HasRoleLevel2(ctx) {
		return status.StatusForbidden()
	}

	_, err = cc.UpdateOne(ctx, bson.M{"_id": id}, update)
	if err != nil {
		return status.StatusInternalServer(err)
	}
	return nil
}
