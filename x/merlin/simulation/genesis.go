package simulation

import (
	"encoding/hex"
	"encoding/json"
	"fmt"
	"math/rand"

	"github.com/cosmos/cosmos-sdk/types/module"
	simtypes "github.com/cosmos/cosmos-sdk/types/simulation"

	"github.com/merlins-labs/merlin/v2/x/merlin/types"
)

const (
	ibcCroDenomKey          = "ibc_mer_denom"
	ibcTimeoutKey           = "ibc_timeout"
	merlinAdminKey          = "merlin_admin"
	enableAutoDeploymentKey = "enable_auto_deployment"
)

func GenIbcCroDenom(r *rand.Rand) string {
	randDenom := make([]byte, 32)
	r.Read(randDenom)
	return fmt.Sprintf("ibc/%s", hex.EncodeToString(randDenom))
}

func GenIbcTimeout(r *rand.Rand) uint64 {
	timeout := r.Uint64()
	return timeout
}

func GenMerlinAdmin(r *rand.Rand, simState *module.SimulationState) string {
	adminAccount, _ := simtypes.RandomAcc(r, simState.Accounts)
	return adminAccount.Address.String()
}

func GenEnableAutoDeployment(r *rand.Rand) bool {
	return r.Intn(2) > 0
}

// RandomizedGenState generates a random GenesisState for the merlin module
func RandomizedGenState(simState *module.SimulationState) {
	// merlin params
	var (
		ibcCroDenom          string
		ibcTimeout           uint64
		merlinAdmin          string
		enableAutoDeployment bool
	)

	simState.AppParams.GetOrGenerate(
		simState.Cdc, ibcCroDenomKey, &ibcCroDenom, simState.Rand,
		func(r *rand.Rand) { ibcCroDenom = GenIbcCroDenom(r) },
	)

	simState.AppParams.GetOrGenerate(
		simState.Cdc, ibcTimeoutKey, &ibcTimeout, simState.Rand,
		func(r *rand.Rand) { ibcTimeout = GenIbcTimeout(r) },
	)

	simState.AppParams.GetOrGenerate(
		simState.Cdc, merlinAdminKey, &merlinAdmin, simState.Rand,
		func(r *rand.Rand) { merlinAdmin = GenMerlinAdmin(r, simState) },
	)

	simState.AppParams.GetOrGenerate(
		simState.Cdc, enableAutoDeploymentKey, &enableAutoDeployment, simState.Rand,
		func(r *rand.Rand) { enableAutoDeployment = GenEnableAutoDeployment(r) },
	)

	params := types.NewParams(ibcCroDenom, ibcTimeout, merlinAdmin, enableAutoDeployment)
	merlinGenesis := &types.GenesisState{
		Params:            params,
		ExternalContracts: nil,
		AutoContracts:     nil,
	}

	bz, err := json.MarshalIndent(merlinGenesis, "", " ")
	if err != nil {
		panic(err)
	}
	fmt.Printf("Selected randomly generated %s parameters:\n%s\n", types.ModuleName, bz)

	simState.GenState[types.ModuleName] = simState.Cdc.MustMarshalJSON(merlinGenesis)
}
