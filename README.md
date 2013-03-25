DEP(1) -- basic dependency tracking
===================================

## SYNOPSIS

    dep
    dep add libname [--pre]
    dep rm libname
    dep install

## DESCRIPTION

   * `dep`:
     Checks that all dependencies are met.

   * `dep add`:
     Fetches the latest version of the library in question
     and automatically adds it to your .gems file.

   * `dep rm`:
     Simply removes the corresponding entry in your .gems file.

   * `dep install`:
     Installs all the missing dependencies for you. An important
     point here is that it simply does a `gem install` for each
     dependency you have. Dep assumes that you use some form of
     sandboxing like gs, RVM or rbenv-gemset.


## INSTALLATION

    $ gem install dep

## HISTORY

dep is actually more of a workflow than a tool. If you think about
package managers and the problem of dependencies, you can summarize
what you absolutely need from them in just two points:

1. When you build an application which relies on 3rd party libraries,
it's best to explicitly declare the version numbers of these
libraries.
2. You can either bundle the specific library version together with
your application, or you can have a list of versions.

The first approach is handled by vendoring the library. The second
approach typically is done using Bundler. But why do you need such
a complicated tool when all you need is simply listing version numbers?

We dissected what we were doing and eventually reached the following
workflow:

1. We maintain a .gems file for every application which lists the
libraries and the version numbers.
2. We omit dependencies of dependencies in that file, the reason being
is that that should already be handled by the package manager
(typically rubygems).
3. Whenever we add a new library, we add the latest version.
4. When we pull the latest changes, we want to be able to rapidly
check if the dependencies we have is up to date and matches what
we just pulled.

So after doing this workflow manually for a while, we decided to
build the simplest tool to aid us with our workflow.

- The first point is handled implicitly by dep. You can also specify
a different file by doing dep -f.
- The second point is more of an implementation detail. We thought about
doing dependencies, but then, why re-implement something that's already
done for you by rubygems?
- The third point (and also the one which is most inconvenient), is
handled by dep add.

The manual workflow for `dep add` would be:

    gem search -r "^ohm$" [--pre] # check and remember the version number
    echo "ohm -v X.x.x" >> .gems

If you try doing that repeatedly, it will quickly become cumbersome.

The fourth and final point is handled by typing dep check or simply dep.
Practically speaking it's just:

    git pull
    dep

And that's it. The dep command typically happens in 0.2 seconds which
is something we LOVE.
