package memorial

import (
	"go.mongodb.org/mongo-driver/bson"
)

var memorialPipline = bson.A{
	bson.D{
		{"$lookup",
			bson.D{
				{"from", "commemorations"},
				{"localField", "_id"},
				{"foreignField", "memorial_id"},
				{"as", "commemorations"},
			},
		},
	},
	bson.D{
		{"$project",
			bson.D{
				{"name", 1},
				{"pic_path", 1},
				{"create_by_user_id", 1},
				{"create_at", 1},
				{"commemorations",
					bson.D{
						{"$slice",
							bson.A{
								"$commemorations",
								10,
							},
						},
					},
				},
			},
		},
	},
	bson.D{
		{"$unwind",
			bson.D{
				{"path", "$commemorations"},
				{"preserveNullAndEmptyArrays", true},
			},
		},
	},
	bson.D{{"$sort", bson.D{{"commemorations.create_at", -1}}}},
	bson.D{
		{"$group",
			bson.D{
				{"_id", "$_id"},
				{"name", bson.D{{"$first", "$name"}}},
				{"pic_path", bson.D{{"$first", "$pic_path"}}},
				{"create_by_user_id", bson.D{{"$first", "$create_by_user_id"}}},
				{"create_at", bson.D{{"$first", "$create_at"}}},
				{"comemorations", bson.D{{"$push", "$commemorations"}}},
				{"latest_commemoration_at", bson.D{{"$max", "$commemorations.create_at"}}},
			},
		},
	},
	bson.D{{"$sort", bson.D{{"latest_commemoration_at", -1}}}},
	bson.D{{"$limit", 10}},
}
