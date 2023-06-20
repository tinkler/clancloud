package article

import (
	"github.com/tinkler/clancloud/pkg/nosql"
	"go.mongodb.org/mongo-driver/mongo"
)

const ServiceDB = "article"
const ServiceDBArticleCollection = "article"

func GetNoDBArticleCC() *mongo.Collection {
	return nosql.DB().Database(ServiceDB).Collection(ServiceDBArticleCollection)
}
