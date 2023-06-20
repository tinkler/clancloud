package cauth

import "github.com/tinkler/clancloud/pkg/model/auth"

var (
	userMapUsername map[string]*auth.User
	userMapID       map[string]*auth.User
)

func init() {
	userMapUsername = make(map[string]*auth.User)
	userMapID = make(map[string]*auth.User)
}

func setUserCache(newUserMapID map[string]*auth.User) {
	newUserMapUsername := make(map[string]*auth.User)
	for _, v := range newUserMapID {
		newUserMapID[v.Username] = v
	}
	userMapUsername = newUserMapUsername
	userMapID = newUserMapID
}

func GetUserByUsername(username string) *auth.User {
	return userMapUsername[username]
}
func GetUserByID(id string) *auth.User {
	return userMapID[id]
}

// return user's nickname when exist or
// return uesr's username when exist or
// return '游客'
func GetNicknameByID(id string) string {
	if u, ok := userMapID[id]; ok {
		if u.Nickname != "" {
			return u.Nickname
		}
		return u.Username
	}
	return "游客"
}
