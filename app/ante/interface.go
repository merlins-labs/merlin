package ante

import sdk "github.com/cosmos/cosmos-sdk/types"

type MerlinKeeper interface {
	HasPermission(ctx sdk.Context, account sdk.AccAddress, permissionsToCheck uint64) bool
}
