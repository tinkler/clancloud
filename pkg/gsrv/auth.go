// Code generated by github.com/tinkler/mqttadmin; DO NOT EDIT.
package gsrv
import (
	"context"
	mrz "github.com/tinkler/mqttadmin/mrz/v1"
	"github.com/tinkler/clancloud/pkg/model/auth"
	pb_auth_v1 "github.com/tinkler/clancloud/auth/v1"
	"github.com/tinkler/mqttadmin/pkg/jsonz/sjson"
)


type authGsrv struct {
	pb_auth_v1.UnimplementedAuthGsrvServer
}

func NewAuthGsrv() *authGsrv {
	return &authGsrv{}
}

type AuthUserManagerAllUserStream struct {
	stream pb_auth_v1.AuthGsrv_UserManagerAllUserServer
	m      *auth.UserManager
}
func (s *AuthUserManagerAllUserStream) Context() context.Context {
	return s.stream.Context()
}
func (s *AuthUserManagerAllUserStream) Send(v *auth.User) error {
	res := mrz.NewTypedRes[*pb_auth_v1.UserManager, *pb_auth_v1.User]()
	// data
	res.Data = new(pb_auth_v1.UserManager)
	jd, err := sjson.Marshal(s.m)
	if err != nil {
		return err
	}
	err = sjson.Unmarshal(jd, res.Data)
	if err != nil {
		return err
	}
	// resp
	respByt, _ := sjson.Marshal(v)
	newResp := &pb_auth_v1.User{}
	err = sjson.Unmarshal(respByt, newResp)
	if err != nil {
		return err
	}
	res.Resp = newResp
	
	return s.stream.Send(res.ToAny())
}
func (s *AuthUserManagerAllUserStream) Recv() (*auth.User, error) {
	in, err := s.stream.Recv()
	if err != nil {
		return nil, err
	}
	req := mrz.ToTypedModel[*pb_auth_v1.UserManager, *pb_auth_v1.User](in)
	jd, err := sjson.Marshal(req.Data)
	if err != nil {
		return nil, err
	}
	err = sjson.Unmarshal(jd, s.m)
	argsByt, _ := sjson.Marshal(req.Args)
	newArgs := &auth.User{}
	err = sjson.Unmarshal(argsByt, newArgs)
	return newArgs, err
	
}

func (s *authGsrv) UserManagerAllUser(stream pb_auth_v1.AuthGsrv_UserManagerAllUserServer) error {
	gsStream := &AuthUserManagerAllUserStream{stream, &auth.UserManager{} }
	return gsStream.m.AllUser(gsStream)
}

