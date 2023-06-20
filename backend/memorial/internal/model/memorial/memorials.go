package memorial

import (
	"context"

	"github.com/tinkler/clancloud/backend/memorial/pkg/const/dbc"
	"github.com/tinkler/clancloud/pkg/nosql"
	"github.com/tinkler/mqttadmin/pkg/status"
	"go.mongodb.org/mongo-driver/bson"
)

type Memorials struct {
	// min 1
	Page int64
	// default 10
	PageSize int64
	Total    int64
}

func (m *Memorials) Load(ctx context.Context) ([]*Memorial, error) {
	if m.PageSize <= 0 {
		m.PageSize = 10
	}
	if m.Page <= 0 {
		m.Page = 1
	}

	memorialCC := nosql.DB().Database(dbc.ServieDB).Collection(memorialCollection)
	var err error
	// m.Total, err = memorialCC.CountDocuments(
	// 	ctx, bson.D{},
	// )
	// if err != nil {
	// 	return nil, status.StatusInternalServer(err)
	// }

	pipeline := []bson.M{
		{
			"$facet": bson.M{
				"data": memorialPipline,
				"count": []bson.M{
					{
						"$count": "total_count",
					},
				},
			},
		},
	}

	// findOption := options.Find()
	// findOption.SetSort(bson.D{{Key: "name", Value: 1}})
	// findOption.SetLimit(m.PageSize)
	// findOption.SetSkip((m.Page - 1) * m.PageSize)

	cur, err := memorialCC.Aggregate(ctx, pipeline)
	if err != nil {
		return nil, status.StatusInternalServer(err)
	}
	defer cur.Close(ctx)

	type pipeStruct struct {
		Data  []*Memorial `json:"data"`
		Count []bson.M    `json:"count"`
	}
	result := new(pipeStruct)
	if cur.Next(ctx) {
		if err := cur.Decode(result); err != nil {
			return nil, status.StatusInternalServer(err)
		}
		m.Total = int64(result.Count[0]["total_count"].(int32))
		return result.Data, nil
	} else {
		// no data
		return nil, nil
	}

}
