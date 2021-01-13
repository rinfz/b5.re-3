@title DasBetterC and pthread
@date 2019-10-23

Recently I was poking around writing some plain C code but stopped pretty soon as I realised my options for writing a generic std::vector style container were pretty limited to copy and paste or rely on `void*` (not a C person so there are probably more options).

That's when I remembered about D's [betterC mode](https://dlang.org/spec/betterc.html). The long and short of it is D without a runtime so missing out on some nice things like [classes](https://dlang.org/phobos/object.html) and the introspection that comes with that, amongst some other things.

On the other hand you essentially get 90% of D and all the good modern features that come with it, like unit tests, modules, templates and metaprogramming, RAII, slices, array bounds checks, destructors etc etc. In this respect it is more of a C++-lite than D is usually. But compact binaries and no GC are sometimes an appealing prospect.

Anyway... I have a project in D which is heavy on the threading side of things and the documentation for betterC states `core.thread` is not available. So I went looking for examples of `<pthread.h>` and came across: [pthreads in C - a minimal working example](http://timmurphy.org/2010/05/04/pthreads-in-c-a-minimal-working-example/). From there it was trivial to get an MVP in D (I doubt I will take this train of thought too far as I dread the idea of making it cross compatible).

Start with some declarations from `<pthread.h>` and `<pthreadtypes.h>`:

@snippet 1.d

Note that we use D's syntax for declaring a function pointer `T function(U) name` rather than C's style.

Then create a function which we will call from the thread:

@snippet 2.d

Nothing special here really. Then finally create the main function:

@snippet 3.d

* We have to say our main is `extern(C)` for DasBetterC mode.
* pthread functions are called as usual.
* This is almost identical to the C version - nice.

Compile it with the following command:

`dmd -betterC -L=-lpthread example.d`

Running should print the following:

```
Done on thread
x=100, y=100
```