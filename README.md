Golang Demo
==============

This is an example Golang project using Nix to setup a development environment.

This relies on using Go 1.11 or above, as we don't use `GOPATH` global workspace style. Instead this is project based as that fits into Nix better. However a shared global workspace is mediated via the Nix system instead.

Check if there are headers and stuff to include? And other environment variables to acquire.

---

Figure out how to use `buildGoPackage` or `buildGo19Package`, since that relies on GOPATH, and this will not use it.

Because Go relies on DNS to acquire dependencies. The main thing is that go modules can do this now with `go.mod` file. And it still acquire dependencies using the DNS.


Looks like though some of it can be handled by nix. Where nix is basically used to specify the actual dependencies, build up an isolated GOPATH workspace and build everything from there. Except for IPFS like go packages which work with gx, which does it completely different thing lol.

Ok so there's a new tool called dep that seems to be the official experiment for a vendoring tool.

As the guy from google says, he preferred godep instead, so we can use that for vendoring, and it apparently it automatically figures out the gopath as well. Every go dev has their own packaging tool which requires a completely different system LOL.

dep 0.4.1 has been released I wonder if we can get this.

So apparently we can have a subdir under `$GOPATH/src/myproject` and that is good enough as well.

Wait apparently we can treat the GOPATH as a single project. However dep does not yet suppor this. That means `$GOPATH/src` is the root.

So we should be a ble to set that as the root. But still this means our nix-shell launches from within?

So let's say we have a directory with src in it. Our repo is now dual in a way. Well... now I'm not sure.

So we have to have GOPATH/src/projectname/main.go.

Unfortunately we don't have GOPATH/src/main.go.

The `dep` is still 0.3.1.

Oh GOPATH is actually capable of referring to multiple areas. Like `/path:/path`. Which can refer to other go dependencies, which are each their own workspace.

You can see that within the repo, src and shit are actually there. LOL.

So that should mean there's a .gitignore file that ignores the bin and pkg.

Yep that's exactly it!

Oh so yea...

So we just need to point our GOPATH to here as well?

Oh so we can just use our pkg normally and get packages from the outside as well.

So you do need `example` as well.

Ok so we create a `src/example` which doesn't have anything else. So we use this as the full repository. Within this project we use `dep init`. (Remember we had to set the current directory as our GOPATH directory as well).

So no we have example. And inside we have `vendor` and `Gopkg.lock` and `Gopkg.toml`.

Nix's go has a package hook as well.

So this is a dep example, but any IPFS code would have to be gx, but I don't even want to touch that atm.

Conventionally the main file is also the same name as the package name.

So the package name might be `example`, then the main file would be `example/example.go`. Not `main.go`, but inside there would be `package main` with a `main ()` function.

However if it is a library, instead you would use `package example` and then just declare normal functions.

So may have combined libraries and applications, you would have `example/example.go` as the main app, and `example/utility.go` as your libaries. Not sure if it's in the same package namespace.

It appears that the package namespace can be the name of the directory that contains the files.

Go by default uses tabs with tab width of 8.

Ok...

Afterwards you can do this: `go install example`, which puts the resulting binary into your `bin/example`. If you have this ignored, then it works great! Or while you're inside `example`, you can just run `go install`.

---

Ensuring dependencies:

```
dep init
dep ensure -add github.com/pelletier/go-toml
dep ensure
```

Right now dep is the most "official" package manager.

However our way of structuring our go package in order to work with nix means we keep the entire bin/pkg/src in our repository, while ignoring bin and pkg. This does mean any other user who would want to use our code as a library, and if we were to expose the it as a library, would require to import: `github.com/MatrixAI/go-repo/src/package`. And then use `package.Func` in hteir code. It's not that bad, and we get integration into Nix!

So this creates a development environment for `shell.nix`, if you wanted to export the application itself, you would write a `default.nix` which uses `go2nix` to get everything.

Alternatively, go packages don't have nix, and then you wrap it in a submodule in a main repository that you work from. That way things can use the submodule, or use your main module. But maintaining submodules does require a bit of work, since you may need to synchronise it. It means you have something like `go-repo`, and then `nix-go-repo` that wraps it and works with as a submodule. So you would have to use the nix repo when working in nix, and you just wrap the main thing, then others can import `github.com/go-repo/packagename`.

https://imagej.net/Git_submodule_tutorial is also good, as it shows how to do this with submodules.

You can still use `go get` here.

---

Ok so we are using Go 1.11 modules here. It appears to assume that `go.mod` is located at the root directory. What exactly does that mean here? Let's see what happens.


```
GOROOT=/home/cmcdragonkai/Downloads/go /nix/store/d54amiggq6bw23jw6mdsgamvs6v1g3bh-glibc-2.25-123/lib64/ld-linux-x86-64.so.2 /home/cmcdragonkai/Downloads/go/bin/go
```

For tests, we are just going to do the above and initialise the module here.

It automatically uses the github remote origin. Otherwise you have the name it accordingly. Still I don't like it, because now we are relying on the code knowing where it is located. Then again the problem is that you don't control that name. Well.. I guess you don't control the NPM name either, so it's really any different. Which is why it makes sense to use a blockchain eventually to do this to be really between people, and therefore I think eventually Polykey will lead to that.

```
go init module
```

Now when you run build what does it actually build? Can you build a single piece of code without a main function? I think the main function is about building executables. What about libraries? I think the package main can be a standard.

```
So the package name might be `example`, then the main file would be `example/example.go`. Not `main.go`, but inside there would be `package main` with a `main ()` function.

However if it is a library, instead you would use `package example` and then just declare normal functions.

So may have combined libraries and applications, you would have `example/example.go` as the main app, and `example/utility.go` as your libaries. Not sure if it's in the same package namespace.
```

You do something like `demo` directory. Inside a `package main`, and a `main.go`.

What are you building? There should be a `demo.go`. In there, what is the package. It should be `package main`. So do we separate the 2?

When you do `go build` on a directory with a `go.mod`, it uses the module name as the name of the output. You need the main package with the main function. If you don't have the main package, nothing will happen. The main package MUST have the `main` function. It takes the basename of your package and builds it. For packages it builds silently and discards results, to see if it builds and typechecks. It's like stack build for a library in a way. It always stores it into the current directory. So you want to ignore things? `go build -o bin/elf`. It always only builds 1 executable! What if you have multiple executables to buid?

Because they inherit the name of the directory they are in. Using main.go is the way to go for that. However an alternative way is to use bin and just build them directly, in which case they will use the name of the file itself. I think that makes more sense than naming them both main.go in their own directory.

```
go build -o bin/hello bin/hello.go
go build -o bin/world bin/world.go
```

There you go. Multiple binaries in the same place.

Note that the `package` namespace IS not the same as the module name, the module name is just any DNS, but usually the basename is the same name. But that's not necessarily true.

---

Now any file that exists on the project root level represents the top level namespace. All go files should have the same namespace here, and this represents the name of the actual package. Whereas the module name is the `go.mod` name.

Now how do you import?

Note that when you import, at the top level you must use the module name (which is the DNS name)

So ok, that's why I had to import by the module name. Because otherwise it was not able to find it. Now that name could be demo. But the module name is meant to be "globally" addressable. In the case of other code, they are using the DNS link. We could use `matrix.ai/...`.

---


[[constraint]]
  name = "github.com/pelletier/go-toml"
  version = "1.1.0"

```

	config, _ := toml.Load(`
        [postgres]
        user = "cmcdragonkai"
        password = "blah"
	`)
	user := config.Get("postgres.user").(string)
	user = utilstring.Reverse(user)
	user = reverse(user)
	fmt.Println(fmt.Sprintf("Hello World %s", user))
```

---



* https://scene-si.org/2018/01/25/go-tips-and-tricks-almost-everything-about-imports/

We should always alias our imports to be more stable, otherwise it just uses the package namespace name.

Also our libraries should be named `go-toml`. Or something like that.

Note that, it will still use the default `GOPATH` called `~/go` on Linux systems. This will cache the installation of the dependencies. Alternatively you can set `GOPATH=./.go` to ensure that you can get your own dependency versions there to isolate it into the project. Actually you can use `$(pwd)`. Since `.` really means the same thing in the shell.nix, well wherever the shell is running. But pwd as well. It's just that nix ensurs that it's in wherever the file it is located. The reason you don't do that is because it brings the entire directory in as a dependency. Becuase it thinks you may refer to it.

If ou do this the GOPATH cannot be set like that. So weird! It has to be outside the GOPATH. So you have to enable GO111MODULES.

I see now. But usually you have to change it over. This ensures it can be put here.


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
