# Rusic - Music Player

## Desktop build notes

The Linux desktop build expects a working C++ toolchain and linker. If CMake reports that it cannot find `ld` or `ld.lld`, install the system linker package for your distribution and then run `flutter clean` before rebuilding.

Inside VS Code, the workspace terminal prepends `toolchain/linux/bin` to `PATH` so the local shims can satisfy the native asset build on Linux.

