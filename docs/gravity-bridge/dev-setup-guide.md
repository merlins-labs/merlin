# Gravity Bridge Dev Setup Guide

## Prerequisite

### Binaries

- `geth`, the go-ethereum binary.
- `merlind`, the merlin node binary.
- `gorc`, the gravity bridge orchestrator cli, built from the [crypto-org fork](https://github.com/crypto-org-chain/gravity-bridge/tree/v2.0.0-merlin/orchestrator/gorc).
- `pystarport`, a tool to run local cosmos devnet.
- `start-geth`/`start-merlin`, convenient scripts to start the local devnets.

Clone merlin repo locally and run `nix-shell integration_tests/shell.nix` in it, you'll get a virtual shell with the
above essential binaries setup in `PATH`.

### Ethereum Testnet

You can either use a public testnet, or run `start-geth /tmp/test-geth` to get a local Ethereum testnet.

You should own some funds in this testnet, for the local testnet, you can get the funds using this mnemonic words:
`visit craft resemble online window solution west chuckle music diesel vital settle comic tribe project blame bulb armed
flower region sausage mercy arrive release`.

### Merlin Testnet

You can either use a public merlin testnet (that have embed the gravity-bridge module), or run `start-merlin
/tmp/test-merlin` to get a local Merlin testnet.

You should own some funds in this testnet, for the local testnet, you'll get the funds with the same private key as
above.

## Generate Orchestrator Keys


You need to prepare two accounts for the orchestrator, one for ethereum and one for merlin. You should transfer some funds to these accounts, so the orchestrator can cover the gas fees of message relaying later.

### Creating the config:

We will use the below `config.toml` to specify the directory where the keys will be generated and some of the configs needed to run the orchestrator. Create a `gorc.toml` file in the same directory as `gorc` and paste the following config:


```toml
keystore = "/tmp/keystore"

[gravity]
contract = "0x0000000000000000000000000000000000000000" # TO BE UPDATED - gravity contract address on Ethereum network
fees_denom = "basetmer"

[ethereum]
key_derivation_path = "m/44'/60'/0'/0/0"
rpc = "http://localhost:8545" # TO BE UPDATED - EVM RPC of Ethereum node

[cosmos]
gas_price = { amount = 5000000000000, denom = "basetmer" }
grpc = "http://localhost:9090" # TO BE UPDATED - GRPC of Merlin node
key_derivation_path = "m/44'/60'/0'/0/0"
prefix = "tcrc"

[metrics]
listen_addr = "127.0.0.1:3000"
```

The keys below will be created in `/tmp/keystore` directory.


### Creating a Merlin account:

```shell
gorc -c gorc.toml keys cosmos add orch_mer
```

Sample output:
```
**Important** record this bip39-mnemonic in a safe place:
lava ankle enlist blame vast blush proud split position just want cinnamon virtual velvet rubber essence picture print arrest away size tip exotic crouch
orch_mer        tdid:fury:iaa1ypvpyjcny3m0wl5hjwld2vw8gus2emtzmur4he
```

### Creating an Ethereum account:

Using the `gorc` binary, you can run:

```shell
gorc -c gorc.toml keys eth add orch_eth
```

Sample out:
```
**Important** record this bip39-mnemonic in a safe place:
more topic panther diesel grace chaos stereo timber tired settle target carbon scare essence hobby worry sword vibrant fruit update acquire release art drift
0x838a3EC266ddb27f5924989505cBFa15fAf88603
```
The second line is the mnemonic and the third one is the public address.

To get the private key (optional), in Python shell:

```python
from eth_account import Account
Account.enable_unaudited_hdwallet_features()
my_acct = Account.from_mnemonic("mystery exotic patch broom sweet sense grocery carpet assist oxygen fault peanut muffin hole popular excite apart fetch lens palace soccer paddle gaze focus") # please use your own mnemnoic
print(my_acct.privateKey.hex()) # Ethereum private key. Keep private and secure e.g. '0xe9580d74831b9611c9680ecde4ea016dee55643fe86901708bafd90a8ef716b6'
```
Note that `eth_account` python package needs to be installed.

## Sign Validator Address

To register the orchestrator with the validator, you need to sign a protobuf encoded message using the orchestrator's
ethereum key, and send it to a merlin validator to register it.

The protobuf message is like this:

```protobuf
message DelegateKeysSignMsg {
  // The valoper prefixed merlin validator address
  string validator_address = 1;
  // Current nonce of the validator account
  uint64 nonce = 2;
}
```

Use your favorite protobuf library to encode the message, and use your favorite web3 library to do the messge signing,
for example, this is how it could be done in python:

```python
msg = DelegateKeysSignMsg(validator_address=val_addr, nonce=nonce)
sign_bytes = eth_utils.keccak(msg.SerializeToString())

acct = eth_account.Account.from_key(...)
signed = acct.sign_message(eth_account.messages.encode_defunct(sign_bytes))
return eth_utils.to_hex(signed.signature)
```

## Register Orchestrator With Merlin Validator

At last, send the orchestrator's ethereum address, merlin address, and the signature we just signed above to a Merlin
validator, the validator should send a `set-delegate-keys` transaction to merlin network to register the binding:

```shell
$ merlind tx gravity set-delegate-keys $val_address $orchestrator_merlin_address $orchestrator_eth_address $signature
```

## Deploy Gravity Contract On Ethereum

The gravity contract can only be deployed after majority validators (66% voting powers) have registered the
orchestrator. And before deploy gravity contract, we need to prepare the [parameters for the
constructor](https://github.com/PeggyJV/gravity-bridge/blob/cfd55296dfb981dd7a18cefa2da9e21410fa0403/solidity/contracts/Gravity.sol#L561)
first:

- `gravity_id`. Run command `merlind q gravity params | jq ".params.gravity_id"`
- `threshold`, constant `2834678415`, which is just `int(2 ** 32 * 0.66)`.
- `eth_addresses` and `powers`:
  - Query signer set by running command: `merlind q gravity latest-signer-set-tx | jq ".signer_set.signers"`
  - Sum up the `power` field to get `powers`
  - Collect the `ethereum_address` field into a list to get `eth_addresses`

At last, use your favorite web3 library/tool to deploy the gravity contract with the above parameters in the ethereum
testnet, the compiled artifacts of the contract (`Gravity.json`) can be found in [gravity-bridge's
releases](https://github.com/PeggyJV/gravity-bridge/releases).

## Run Orchestrator

```shell
./gorc -c ./gorc.toml orchestrator start \
		--cosmos-key="orch_mer" \
		--ethereum-key="orch_eth"
```

After all the orchestrator processes run, the gravity bridge between ethereum and merlin is setup succesfully.
