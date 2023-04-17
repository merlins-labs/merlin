{
  dotenv: '../../scripts/.env',
  'merlin_777-1': {
    cmd: 'merlind',
    'start-flags': '--trace',
    config: {
      mempool: {
        version: 'v1',
      },
    },
    'app-config': {
      'app-db-backend': 'pebbledb',
      'minimum-gas-prices': '0basetmer',
      'index-events': ['ethereum_tx.ethereumTxHash'],
      'iavl-lazy-loading': true,
      'json-rpc': {
        address: '0.0.0.0:{EVMRPC_PORT}',
        'ws-address': '0.0.0.0:{EVMRPC_PORT_WS}',
        api: 'eth,net,web3,debug,merlin',
        'feehistory-cap': 100,
        'block-range-cap': 10000,
        'logs-cap': 10000,
      },
      store: {
        streamers: ['file'],
      },
      streamers: {
        file: {
          write_dir: 'data/file_streamer',
        },
      },
    },
    validators: [{
      coins: '1000000000000000000stake,10000000000000000000000basetmer',
      staked: '1000000000000000000stake',
      mnemonic: '${VALIDATOR1_MNEMONIC}',
      'app-config': {
        store: {
          streamers: ['file', 'versiondb'],
        },
      },
    }, {
      coins: '1000000000000000000stake,10000000000000000000000basetmer',
      staked: '1000000000000000000stake',
      mnemonic: '${VALIDATOR2_MNEMONIC}',
    }],
    accounts: [{
      name: 'community',
      coins: '10000000000000000000000basetmer',
      mnemonic: '${COMMUNITY_MNEMONIC}',
    }, {
      name: 'signer1',
      coins: '20000000000000000000000basetmer',
      mnemonic: '${SIGNER1_MNEMONIC}',
    }, {
      name: 'signer2',
      coins: '30000000000000000000000basetmer',
      mnemonic: '${SIGNER2_MNEMONIC}',
    }],
    genesis: {
      consensus_params: {
        block: {
          max_bytes: '1048576',
          max_gas: '81500000',
        },
      },
      app_state: {
        evm: {
          params: {
            evm_denom: 'basetmer',
          },
        },
        merlin: {
          params: {
            merlin_admin: '${MERLIN_ADMIN}',
            enable_auto_deployment: true,
            ibc_mer_denom: '${IBC_CRO_DENOM}',
          },
        },
        gov: {
          voting_params: {
            voting_period: '10s',
          },
          deposit_params: {
            max_deposit_period: '10s',
            min_deposit: [
              {
                denom: 'basetmer',
                amount: '1',
              },
            ],
          },
        },
        transfer: {
          params: {
            receive_enabled: true,
            send_enabled: true,
          },
        },
        feemarket: {
          params: {
            no_base_fee: false,
            base_fee: '100000000000',
          },
        },
      },
    },
  },
}
