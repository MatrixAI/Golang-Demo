{ pkgs ? import ./pkgs.nix }:

with pkgs;
let
  drv = callPackage ./default.nix {};
in
  drv.overrideAttrs (attrs: {
    src = null;
    nativeBuildInputs = [ govers ] ++ attrs.nativeBuildInputs;
    shellHook = ''
      echo 'Entering ${attrs.pname}'
      set -v

      export GOPATH="$(pwd)/.go"
      export GOCACHE=""
      export GO111MODULE='on'

      set +v
    '';
  })
