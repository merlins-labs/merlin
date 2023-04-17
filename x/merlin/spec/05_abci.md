<!--
order: 5
-->

# ABCI

## InitGenesis

`InitGenesis` initializes the Merlin module genesis state by setting the `GenesisState` fields to the
store. In particular it sets the parameters and token mapping state.

## ExportGenesis

The `ExportGenesis` ABCI function exports the genesis state of the Merlin module. In particular, it
iterates all token mappings to genesis.
