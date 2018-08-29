{
  pkgs ? import ./pkgs.nix,
  goPath ? "go_1_11"
}:
  with pkgs;
  let
    go = lib.getAttrFromPath (lib.splitString "." goPath) pkgs;
    buildGoPackage = pkgs.buildGoPackage.override { inherit go; };
  in
    buildGoPackage {
      name = "golang-demo";
      version = "0.0.1";
      goPackagePath = "github.com/MatrixAI/Golang-Demo";
      src = lib.cleanSourceWith {
        filter = (path: type:
          ! (builtins.any
              (r: (builtins.match r (builtins.baseNameOf path)) != null)
              [
                "\.env"
                ".go"
              ])
        );
        src = lib.cleanSource ./.;
      };
      goDeps = ./deps.nix;
    }
