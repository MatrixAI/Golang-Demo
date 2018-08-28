# Golang Demo

This is an example Golang project using Nix to setup a development environment.

This relies on using Go 1.11 or above, as we don't use `GOPATH` global workspace style. Instead this is project based as that fits into Nix better. However a shared global workspace is mediated via the Nix system instead.

To start a new Golang module project:

```sh
# by default it will use the remote origin as the module name
go mod init
# go mod init custom-module-name
```

A Golang module is basically a "package" meaning a bundle of namespaced code. A golang package is basically a "module" meaning an importable namespaced code. The Golang module name is usually a DNS address that points to version controlled repository because Golang does not have a dedicated package registry. That is, Golang uses the DNS system as its package registry. However you can actually give it any module name, it just won't be downloadable by any Golang package manager. This is why we have named this Golang module: `github.com/MatrixAI/Golang-Demo`.

However this creates some problems. The main problem is that using a DNS address is probably not as stable as using a unique name on a dedicated package registry. After all I may want to later host this code on Gitlab or Bitbucket or self-hosted. But the source code is now hardcoding this name. One way to deal with this is to use a vanity DNS name. Basically run your own DNS server, or register some internet property and point that to wherever your code will be hosted on.

At any case, if your names change or whatever reason, whether it is your own module name, or one of your dependency's name, you will need to change the import paths in all of your source code. To do this easily, you can use the `govers` tool:

```sh
govers -d -m 'github.com/MatrixAI/Golang-Demo' 'gitlab.com/MatrixAI/Golang-Demo'
```

When you enter the `nix-shell`, all the module dependencies will be automatically downloaded, because the `shellHook` runs:

```sh
go mod download
```

There are more Golang module commands:

```sh
go help mod
```

You can build the package:

```sh
# buildGoPackage is a multiple-output derivation
# with a bin output and all
nix-build ./default.nix
nix-build ./default.nix --attr all
```

Note that the default `$GOPATH` and `$GOCACHE` is `~/go` and `~/.cache/go-build` respectively. However when entering the `nix-shell`, the `$GOPATH` will be set to `./.go`, this is to prevent other projects causing side effects to the `$GOPATH`. We don't trust the `$GOPATH` for sharing unlike the `/nix/store`.

The `~/.go` can be deleted, however it requires forcing deletion because some of its directories disable the write permission: `sudo rm -rf ./.go`.

To automatically convert `go.mod` to `deps.nix` required by `buildGoPackage`, use https://github.com/adisbladis/vgo2nix Note that this still doesn't allow you to share dependencies between Nix and Golang Modules when using nix-shell.

There is an alternative to using `deps.nix`, which is to specify `extraSrcs`:

```nix
extraSrcs = [
  {
    goPackagePath = "github.com/pelletier/go-toml";
    src = fetchFromGitHub {
      owner = "pelletier";
      repo = "go-toml";
      rev = "acdc4509485b587f5e675510c4f2c63e90ff68a8";
      sha256 = "1y5m9pngxhsfzcnxh8ma5nsllx74wn0jr47p2n6i3inrjqxr12xh";
    };
  }
];
```

You may wonder whey we cannot just use `buildInputs` like other language environments in Nix. This is because Golang dependencies is the Go source code, not the compiled outputs such as the executables, static objects or shared objects. This means adding a Go package to the `buildInputs` will most likely only bring in the compiled executables if it has any and nothing else (becuase by default Go will not produce static or shard objects). This means Golang dependencies is closer to something you combine with your `src`. If you look at the `buildGoPackage` function, you will find it just loads the source code and composes a `GOPATH` that contains paths to the dependency source code. This is also the most likely reason the mainline Nixpkgs does not contain expressions for Golang code unless they are Golang code that produces executables.

We have not yet addressed Cgo where Golang binds to C libraries.

## Further reading:

* https://github.com/NixOS/nixpkgs/pull/45630
* https://golang.org/cmd/go/#hdr-Environment_variables
* https://scene-si.org/2018/01/25/go-tips-and-tricks-almost-everything-about-imports/
* https://github.com/NixOS/nixpkgs/archive/86c4c0699aad5331da6950dfa0727d19ddc3ce09.tar.gz
* https://nixos.wiki/wiki/Go
