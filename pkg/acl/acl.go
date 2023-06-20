package acl

import (
	"context"

	"github.com/tinkler/mqttadmin/pkg/acl"
)

const (
	RoleClansLevel2 = "clans_level_2"
	RoleClansLevel3 = "clans_level_3"
	RoleClansLevel4 = "clans_level_4"
	RoleClansLevel5 = "clans_level_5"
)

func HasRoleLevel6(ctx context.Context) bool {
	return acl.HasRole(ctx, acl.RoleUser)
}

func HasRoleLevel5(ctx context.Context) bool {
	return acl.HasRole(ctx, RoleClansLevel5, RoleClansLevel4, RoleClansLevel3, RoleClansLevel2)
}

func HasRoleLevel4(ctx context.Context) bool {
	return acl.HasRole(ctx, RoleClansLevel4, RoleClansLevel3, RoleClansLevel2)
}

func HasRoleLevel3(ctx context.Context) bool {
	return acl.HasRole(ctx, RoleClansLevel3, RoleClansLevel2)
}

func HasRoleLevel2(ctx context.Context) bool {
	return acl.HasRole(ctx, RoleClansLevel2)
}

func HasRoleLevel1(ctx context.Context) bool {
	return acl.HasRole(ctx)
}

func GetUserID(ctx context.Context) string {
	return acl.GetUserID(ctx)
}
