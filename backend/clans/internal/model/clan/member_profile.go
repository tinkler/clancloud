package clan

type MemberProfile struct {
	ID          int64
	PicPath     string
	PersonalURL string
	Homeplace   string
	Address     string
	Telephone   string
}

func (m *MemberProfile) TableName() string {
	return "v1.member_profile"
}
