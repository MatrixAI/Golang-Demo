Docker Demo
==============

This shall host a demo code running docker golang source inside a nix-shell environment.

Here we find out that `goPackages` has been removed. So where is the support functions for creating a golang environment so I can make it be used on non-nixos environments?

It needs to bring in go, and go can bring in the necessary packages as well.

Oh so it's basically pkgs.buildGoPackage. And this probably points to `buildGo19Package` or whatever. Hard to say without searching through the nix codebase. Yeap  I can see that it's `buildGo19Package` from the top level packages.

Remember how you used that emscripten thing....

Notice that whenever you use an environment that has a langauge that requires compilation that's when it involves a much more complicated environment due to the multistaging of the language. Haskell, go all require a much more sophisticated shell environment. JS is the easiest to integrate into nix simply by using a nix-shell and npm. It's also cause JS is one of the only language to start with a localised isolation project-directory point of view, whereas all the other things start out with global directory positions and that includes things like python as well.

---

So a weird situation with golang is that a go workspace contains multiple git repostories. Rather than the project repo we exactly want, our individual golang code lives in these `src/github.com/user/repo` directories. So we actually have multiple repostories here. So how is it that we are writing golang, but not having a proper shell.nix for a single repository?

Basically here under golang code. You have to create a special golang workspace area, your shell.nix is for that workspace area. But inside this workspace, you can have bin/pkg/src, and these are actually the go code. So you wouldn't have individual shell.nix for each golang repository. That's pretty dumb. That's really quite dumb lol!

Because now our shell.nix is not kept along with the actual go project.

Go 1.6 has vendoring support though. I should be able to do this without the full gopath.

Code below a directory named vendor is importable only by code in the directory tree rooted at the parent of vendor, and only using an import path that omits the prefix up to and including the vendor element.

So this still has to be inside the the `$GOPATH/src/project/name/b.go`.

Basically you can have a vendor directory. That basically means you can put packages into there, and your project can import it. But the whole thing still has to be in a GOPATH, which has bin, src, pkg. Can we do this without git?

Suppose I use vendoring with GOPATH set to the current directory and always set to the main thing. Suppose that could still work, I just need to always set a package path.

Does the package path need to be a github.com path? Why not something else?

Man fundamentally this ruins everything.

Note that there are 3 things: govendor, godeps, gx-go, these are the package manager tooling that has developed around vendoring.

Just like C, golang code appears to be written with the idea that vendoring means all your dependency code gets committed to source instead of being fetched lazily by a package manager. We can use git submodules or vendoring folder or whatever.

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

