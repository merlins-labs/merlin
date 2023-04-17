<!-- order: 4 -->

# Messages

## MsgConvertVouchers

> Normally user should use Merlin smart contract to do this, no need to use this message directly.

Convert native tokens to the mapped CRC20 tokens, if the mapping does not exist and auto-deployment is enabled, an embed CRC20 contract is deployed for it automatically, otherwise, the message fails.

+++ https://github.com/merlins-labs/merlin/blob/v0.6.0-testnet/proto/merlin/tx.proto#L26-L30

This message is expected to fail if:

- The coin denom is neither IBC nor gravity tokens.
- The mapping does not exist and auto-deployment is not enabled.

Fields:

- `address`: Message signer, bech32 address on Merlin.
- `coins`: The coins to convert.

## MsgTransferTokens

> Normally user should use Merlin smart contract to do this, no need to use this message directly.

Transfer IBC tokens (including CRO) away from Merlin chain, decimals conversion is done automatically for CRO.

It calls the ibc transfer module internally, the `timeoutHeight` parameter is hardcoded to zero, the `timeoutTimestamp` parameter is set according the `IbcTimeout` module parameter.

+++ https://github.com/merlins-labs/merlin/blob/v0.6.0-testnet/proto/merlin/tx.proto#L33-L38

This message is expected to fail if:

- The sender doesn't have enough balance.
- The IBC transfer message fails.

Fields:

- `from`: Message signer, bech32 address on Merlin.
- `to`: The destination address of IBC transfer.
- `coins`: The coins to transfer.

## MsgUpdateTokenMapping

Update external token mapping, insert if not exists, can only be called by Merlin admin account, which is configured in module parameters.

+++ https://github.com/merlins-labs/merlin/blob/v0.6.0-testnet/proto/merlin/tx.proto#L47-L51

This message is expected to fail if:

- The sender is not authorized.
- The contract address or denom is malformed.

- The contract is already mapped to anther denom.
