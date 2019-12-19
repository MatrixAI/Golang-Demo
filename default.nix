{ buildGoModule
, nix-gitignore
}:

buildGoModule {
  pname = "golang-demo";
  version = "0.0.1";
  src = nix-gitignore.gitignoreSource [] ./.;
  goPackagePath = "github.com/MatrixAI/Golang-Demo";
  modSha256 = "03977scgfx2mh1dm95f3g5mm5khib82cycn8q28dnk79k8a1g6yh";
}
