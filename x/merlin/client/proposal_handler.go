package client

import (
	govclient "github.com/cosmos/cosmos-sdk/x/gov/client"

	"github.com/merlins-labs/merlin/v2/x/merlin/client/cli"
)

// ProposalHandler is the token mapping change proposal handler.
var ProposalHandler = govclient.NewProposalHandler(cli.NewSubmitTokenMappingChangeProposalTxCmd)
