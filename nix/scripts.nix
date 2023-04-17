{ pkgs
, config
, merlin ? (import ../. { inherit pkgs; })
}: rec {
  start-merlin = pkgs.writeShellScriptBin "start-merlin" ''
    # rely on environment to provide merlind
    export PATH=${pkgs.test-env}/bin:$PATH
    ${../scripts/start-merlin} ${config.merlin-config} ${config.dotenv} $@
  '';
  start-geth = pkgs.writeShellScriptBin "start-geth" ''
    export PATH=${pkgs.test-env}/bin:${pkgs.go-ethereum}/bin:$PATH
    source ${config.dotenv}
    ${../scripts/start-geth} ${config.geth-genesis} $@
  '';
  start-scripts = pkgs.symlinkJoin {
    name = "start-scripts";
    paths = [ start-merlin start-geth ];
  };
}
