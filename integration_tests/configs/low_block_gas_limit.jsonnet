local config = import 'default.jsonnet';

config {
  'merlin_777-1'+: {
    'app-config'+: {
      evm+: {
        'max-tx-gas-wanted': 1,
      },
    },
    config+: {
      consensus+: {
        timeout_commit: '5s',
      },
    },
    genesis+: {
      consensus_params+: {
        block+: {
          max_gas: '815000',
        },
      },
    },
  },
}
