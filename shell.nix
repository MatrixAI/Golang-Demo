{
  pkgs ? import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/d09e425aea3e09b6cec5c7b05cc0603f6853748b.tar.gz) {}
}:
  with pkgs;
  stdenv.mkDerivation {
    name = "docker-demo";
    buildInputs = [ go dep ];
    shellHook = ''
      echo 'Entering Docker Demo Environment'
      set -v

      export GOPATH="$GOPATH:$(pwd)"
      export PATH="$PATH:$(pwd)/bin"

      set +v
    '';
  }
