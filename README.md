Golang Demo
==============

This is an example Golang project using Nix to setup a development environment.

This relies on using Go 1.11 or above, as we don't use `GOPATH` global workspace style. Instead this is project based as that fits into Nix better. However a shared global workspace is mediated via the Nix system instead.


It automatically uses the github remote origin. Otherwise you have the name it accordingly. Still I don't like it, because now we are relying on the code knowing where it is located. Then again the problem is that you don't control that name. Well.. I guess you don't control the NPM name either, so it's really any different. Which is why it makes sense to use a blockchain eventually to do this to be really between people, and therefore I think eventually Polykey will lead to that.

```
go init module
```

Note that the `package` namespace IS not the same as the module name, the module name is just any DNS, but usually the basename is the same name. But that's not necessarily true.

* https://scene-si.org/2018/01/25/go-tips-and-tricks-almost-everything-about-imports/

We should always alias our imports to be more stable, otherwise it just uses the package namespace name.

This is the PR with go 1.11

https://github.com/NixOS/nixpkgs/archive/86c4c0699aad5331da6950dfa0727d19ddc3ce09.tar.gz


```
import (fetchTarball https://github.com/NixOS/nixpkgs-channels/archive/d09e425aea3e09b6cec5c7b05cc0603f6853748b.tar.gz) {}
```

We can try with `buildGoPackage` with src relied internally. I'm not sure if we need do then convert the `go.mod` to the `deps.nix` that `buildGoPackage` expects. If so, then, during nix-shell, we use the same environment, but we don't run the installation? Unless the buildInputs gets specified accordingly. I'm not sure how this system appears to compile. Because the GOPATH will be separate. Basically without the right GOPATH, the nix-shell won't be able to acquire the right data.

Here's what I think should happen, when `buildGoPackage` runs, when the nix-shell enters, we should enter with a predefined GOPATH. Then that GOPATH points to something that already has all the details. Including the dependencies. And EVEN the current project. But because we are in the current directory, the point is that compilation should work. But I have a feeling like it won't work.

Remember the idea is that some other nix package, can use this package, without going through go.mod. It depends, should they use the go package manager or nix pacakge manager? In the case of JS, currently we still use NPM for everything, and we don't just translate it.

ANyway, this will use the go 1.11 first and see if this works, and then test `goBuildPckage`.

Also we need to use `lib.cleanSourceWith` to clean it well, otherwise random binaries and `.go` will be brought in as well. We are still not really using `.gitignore!`.

Use a makefile to then produce a place for the build output. Or whatever build tool. Make is probably the easiest for simple jobs.

Note the use of `nix` when you have a `makefile`, you will need to run: `./configure; make; make install`. Note that `make` will run the default first non `.` target. So by convention that's `all`. That's pretty much it. Note that `make install` will need to target things like the installation prefix. Note that this requires using the prefix being the `$out`. That's just copying stuff. Note that `LC_ALL` affects your build.

Yea, as soon as you enter the shell with `go` in the `buildInput`, you get `GOPATH`. So not even buildGoPackage. That's actually the GOROOT. But yea, that's not writable, so it's a bit weird. You won't even be able to build simply because you need to set the GOPATH appropriately.

Now let's try `buildGoPackage`.


```

    stdenv.mkDerivation {
      name = "golang-demo";
      version = "0.0.1";
      src = lib.cleanSourceWith {
        filter = (path: type:
          ! (builtins.any
              (r: (builtins.match r (builtins.baseNameOf path)) != null)
              [
                ".go"
              ])
        );
        src = lib.cleanSource ./.;
      };
      buildInputs = [ go ];
    }
```

We are running with overrides here. Because there's no `buildGo111Package`. Which is funny. But basically we need to override according to the go version we need. But anyway because we rely on both. Then we need both.

The `buildGoPackage` produces a very different `GOPATH`. So here we go. The `$out` doesn't exist yet, becuase we are in the path. So what does this actually build?

There we go, we do have something very interesting. The problem is that `go` syas that you cannot use go modules with teh build cache disabled. I think that means, you cannot actaully do it this way. Basically building go modules doesn't work.

But the other issue is that whether `go.mod` should even do its job. Here, or do we allow things in the GOPATH to already have what is necessary.

It says it cannot find it. So let's see if we can apply it.

---

So the `nix-build` succeeded even with a `go.mod`. This is because you specify the dependency as required in the GOPATH, and everything just works. However it will complain if it sees that `bin` has the name there. I see.. it tries to find the `main` package. And in this case it inherits the name of bin directory rather than use the name of the file. This is unfortunate, as I had to make sure we had different directories to do this.

Oh yea, and it normally builds `./result-bin` because it selects `bin` by default. Otherwise you need to select the `--attr all` I think. So it builds everything.

Yep by giving the directory a name, the end result is that it works. I wonder what happens if you only had a main here. So `bin/hello.go` and `bin/world.go` doesn't work. It tries to find one main package? If you give them both their own directory, it ends up working. So we could do something like `bin/hello/main.go` and `bin/world/main.go`. That ends up working as well. It's just within the same directory it all gets weird! So that's good.

But we are not using GO111MODULES in that case, the Nix is what brings that in. I don't know if that ends up working as well? Well every time you change `go.mod`, you have to convert it to nix packages, using `vgo2nix` or something like that.

The `go.mod` just uses something similar!? I don't think you then use a diffeerent GOPATH. Oh it's a multiple output:

```
nix-build --attr all
```

Will build a result link and a result-bin link. So it ends up working anyway. The all build just has a nix-support link. I think so it just links to the result-bin` if you install all, you end up getting the bin as well. I'm not sure if that makes sense as as composable go packages. I need a separate package to import the go package and see what happens. Alternatively the whole thing is a buildInputs. It tries to integrate godeps by doing `importGodeps` And you add extra sources and also extra things to the goPath.

The point is that what if we have no binaries? Then it you don't use it, you just use that thing.

---

Using `buildGoPackage` means that you are not directly supporting GO111MODULES. However you do get `govers`. Which allows you to rename import paths. This is pretty cool. But it should be explicitly specified in the `buildInputs`. Since it's a dev tool. I added to the `buildInputs` for `nix-shell`.

So this is pretty cool, we can easily change the import paths really quickly. So it becomes less of a problem referring to the actual path of the package. Especially if the import path also has a version change.

To share dependencies between the `buildGoPackage` and the nix-shell GO111MODULES.

https://golang.org/cmd/go/#hdr-Environment_variables

Yea I don't think it works. Go modules just live in an isolated way, there's no way to work in a shared GOPATH either.


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
