@title Rust struct FFI and Python
@date 2019-10-17

Given a basic struct:

@snippet 1.rs

If you want to use FFI and call this from, say, Python, you can't take Point parameters in functions by reference because it will segfault.

Therefore you have to make use of `*const` and `*mut` for read-only and in/out parameters respectively.

To make the struct eligible for FFI, we whack a `#[repr(C)]` on it. For the purposes of this example, I will just overload the + operator ([ripped straight from the docs](https://doc.rust-lang.org/std/ops/trait.Add.html)).

@snippet 2.rs

Note: this also means we stick `#[derive(Clone, Copy)]` on our Point struct.

I have been separating my FFI interface from the normal rust code as I am working on a dual-purpose codebase where we don't need to export everything so it's nice to keep the public API separate. So just put all the FFI functions in a `mod ffi` similar to how you would separate tests while keeping them in the same file.

@snippet 3.rs

The first example takes two immutable Points and returns a new Point to the caller. We have to use `unsafe` as we are dereferencing the points within the function body. This is nice and succinct.

The second example modifies the first parameter in place by taking it as a mutable pointer. No overload here as we don't want to create a new Point.

Now on the python side of things, we setup using ctypes.

@snippet 1.py

The Point class inheriting from ctypes.Structure is the way to map external structs to Python objects. `_fields_` is special syntax ([docs link](https://docs.python.org/3/library/ctypes.html#ctypes.Structure._fields_)). Add an overload for converting it to a string so we can see things have worked too.

After that Point class, we can load the .so and tell it what each function expects and what we expect it will return. We use `ctypes.POINTER` around the Point class as the rust functions do not expect args by value. `restype = None` is used when a function does not return a value.

After all that setup we can basically just call these functions like we would with any other code.

@snippet 2.py
