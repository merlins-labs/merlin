{ pkgs ? import ../../nix { } }:
let merlind = (pkgs.callPackage ../../. { });
in
merlind.overrideAttrs (oldAttrs: {
  patches = oldAttrs.patches or [ ] ++ [
    ./broken-merlind.patch
  ];
})
