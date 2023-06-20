package memorial

type Commemorate struct {
	ID string `json:"_id" bson:"_id"`
	// related to user id
	PersonID   string `json:"person_id" bson:"person_id"`
	PersonName string
	// 0 上香 1 送花 2 鞠躬 3 悼念
	Event int `json:"event" bson:"event"`
	// RFC3339
	CreateAt string `json:"create_at" bson:"create_at"`
}
