Golang Demo
==============

This is an example Golang project using Nix to setup a development environment.

The main thing to realise that Go dependencies are source code, not compiled outputs (like shared object or static archives to link to).

This relies on using Go 1.11 or above, as we don't use `GOPATH` global workspace style. Instead this is project based as that fits into Nix better. However a shared global workspace is mediated via the Nix system instead.

```
# will auto use the git remote as the module name
go mod init
go mod download
go mod tidy

nix-build ./default.nix --attr all
```

* https://golang.org/cmd/go/#hdr-Environment_variables
* https://github.com/NixOS/nixpkgs/pull/45630
* https://scene-si.org/2018/01/25/go-tips-and-tricks-almost-everything-about-imports/
* https://github.com/NixOS/nixpkgs/archive/86c4c0699aad5331da6950dfa0727d19ddc3ce09.tar.gz
* Investigate vgo2nix

Alternative to `deps.nix`:

```
      # extraSrcs = [
      #   {
      #     goPackagePath = "github.com/pelletier/go-toml";
      #     src = fetchFromGitHub {
      #       owner = "pelletier";
      #       repo = "go-toml";
      #       rev = "acdc4509485b587f5e675510c4f2c63e90ff68a8";
      #       sha256 = "1y5m9pngxhsfzcnxh8ma5nsllx74wn0jr47p2n6i3inrjqxr12xh";
      #     };
      #   }
      # ];
```

Beware of `~/go` and `~/.cache/go-build` which is the default GOPATH and GOCACHE respectively. Note that we enable GOCACHE for the entire nix-shell development, but we isolate the GOPATH even with GO modules to avoid any kind of problems.
