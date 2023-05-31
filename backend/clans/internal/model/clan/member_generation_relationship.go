package clan

// MemberGenerationRelationship write down the generation relationship of each member
// 父子(母子)关系
type MemberGenerationRelationship struct {
	// MainID 一般指父亲,入赘指母亲,必须
	MainID int64 `xorm:"not null unique(nature) INTEGER" validate:"required"` //主属
	// SpouseID 一般指母亲,入赘指父亲,未知为空或0
	SpouseID int64 `xorm:"unique(nature) INTEGER"`                              //配偶
	ChildID  int64 `xorm:"not null unique(nature) INTEGER" validate:"required"` //子女
	// ChildRecognizedGeneration 子女在次关系中的辈分
	ChildRecognizedGeneration int   `xorm:"not null INT(8)" validate:"required|min:1"` //辈分
	AdoptedBy                 int64 `xorm:"INTEGER"`                                   //过继到
	DoubleAdopted             bool  `xorm:"BOOL"`                                      //是否双承
}

// TableName return table name
func (m *MemberGenerationRelationship) TableName() string {
	return "v1.member_generation_relationship"
}
