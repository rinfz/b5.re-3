@date 2019-11-06
@title Collatz conjecture in x86
Been following an [introduction to assembly](https://gitlab.com/mcmfb/intro_x86-64) and one of the exercises was to implement a collatz conjecture function.

My first attempt is as follows (with the arg x chosen at random):

@snippet 1.asm

Then I wrote it in C++ and checked the [godbolt output](https://godbolt.org/z/3gy0-M) to see if I could make any improvements.

Firstly I noticed that it uses a shift instead of a divide (since we always divide by 2) so the 4 instructions needed for that can be switched:

@snippet 2.asm

That then means the cmp we do after the div in the initial version can be changed to a bitwise and to determine if x is even before we do the shift, followed by a test to see if the and resulted in 0.

Finally gcc doesn't use mul so we switch a mov and mul for two adds (presumably lower cycle count? cleaner on the registers at least).

So the end result is the following:

@snippet 3.asm