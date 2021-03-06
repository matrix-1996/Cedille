# The Cédlle Microkernel


The Cédille Microkernel is a microkernel designed to keep a lot of running code outside of the kernel. This means that Cédille is inherently more stable and secure, as core services are run with lowered permissions. Core services are run as daemons in userspace with the same (but possibly heightend) permissions as other processes.

Cédille takes alot of insperation from BSD, as well as the Mach Kernel. The process model takes some insperation from Mach - It uses tasks instead of processes, and uses ports for IPC.
However, Cédille is NOT Mach, nor is it any other kernel. It is just inspired by it. Cédille aims to be more UNIX like then Mach, but still have its own thing going.

### License

This project uses the MIT license:
```
Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

## Building


1. Get a working implementation of gcc / clang / whatever you use to compile.
2. Make sure it cross compiles correctly, and targets the correct thing.
3. Determine an output system (iso,image,elf). If you can't decide, just build an elf for now. (Use `make kernel`)
4. Build the kernel by passing the compiler options directly in from the command line

Example:
On my host machine for building x86:
`make CC=i686-elf-gcc LD=i686-elf-gcc GENISO=genisoimage` which I have aliased to `make_kernel` in bash

Read `doc/Porting Architecture.md` for more info.
