# Golang Demo

This is an example Golang project using Nix to setup a development environment.

This relies on using Go 1.11 or above, as we don't use `GOPATH` global workspace style. Instead this is project based as that fits into Nix better. However a shared global workspace is mediated via the Nix system instead.

Note that the default `$GOPATH` and `$GOCACHE` is `~/go` and `~/.cache/go-build` respectively. However when entering the `nix-shell`, the `$GOPATH` will be set to `./.go`, this is to prevent other projects causing side effects to the `$GOPATH`. We don't trust the `$GOPATH` for sharing unlike the `/nix/store`.

We have already started a Golang project here by running:

```sh
go mod init github.com/MatrixAI/Golang-Demo
```

A Golang module is basically a "package" meaning a bundle of namespaced code. A golang package is basically a "module" meaning an importable namespaced code. The Golang module name is usually a DNS address that points to version controlled repository because Golang does not have a dedicated package registry. That is, Golang uses the DNS system as its package registry. However you can actually give it any module name, it just won't be downloadable by any Golang package manager. This module is named: `github.com/MatrixAI/Golang-Demo`.

You may wonder whey we cannot just use `buildInputs` like other language environments in Nix. This is because Golang dependencies is the Go source code, not the compiled outputs such as the executables, static objects or shared objects. This means adding a Go package to the `buildInputs` will most likely only bring in the compiled executables if it has any and nothing else (becuase by default Go will not produce static or shard objects). This means Golang dependencies is closer to something you combine with your `src`. 

## Installation

Building the package (as a library):

```sh
nix-build -E '(import ./pkgs.nix).callPackage ./default.nix {}'
```

Building the releases:

```sh
nix-build ./release.nix --attr application
nix-build ./release.nix --attr docker
```

Install into Nix user profile:

```sh
nix-env -f ./release.nix --install --attr application
```

Install into Docker:

```sh
docker load --input "$(nix-build ./release.nix --attr docker)"
```

## Development

If your names change or whatever reason, whether it is your own module name, or one of your dependency's name, you will need to change the import paths in all of your source code. To do this easily, you can use the `govers` tool:

```sh
govers -d -m 'github.com/MatrixAI/Golang-Demo' 'gitlab.com/MatrixAI/Golang-Demo'
```

There are more Golang module commands:

```sh
go help mod
```
