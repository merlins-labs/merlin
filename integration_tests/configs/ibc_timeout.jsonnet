local ibc = import 'ibc.jsonnet';

ibc {
  'merlin_777-1'+: {
    genesis+: {
      app_state+: {
        merlin+: {
          params+: {
            ibc_timeout: 0,
          },
        },
      },
    },
  },
}
