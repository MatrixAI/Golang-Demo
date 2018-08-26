{
  pkgs ? import ./pkgs.nix,
  goPath ? "go_1_11"
}:
  with pkgs;
  let
    go = lib.getAttrFromPath (lib.splitString "." goPath) pkgs;
    drv = import ./default.nix { inherit pkgs goPath; };
  in
    drv.overrideAttrs (attrs: {
      src = null;
      buildInputs = [ govers ] ++ attrs.buildInputs;
      shellHook = ''
        echo 'Entering ${attrs.name}'
        set -v

        export GOPATH="$(pwd)/.go"
        export GOCACHE=""
        export GO111MODULE='on'

        set +v
      '';
    })
