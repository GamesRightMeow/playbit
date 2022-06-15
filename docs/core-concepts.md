# Core concepts

## Playbit header
The file [header.lua](/header.lua), referred to as _the header_, contains boiler plate code that allows your Playdate code to run under Love2d. The header must be added to the top of `main.lua` with a [LuaPreprocess insert]() `@@"playbit/header.lua"`

## Macros

This section details available macros to use in your project.

To add your own, refer to the documentation on [macros in LuaPreprocess](http://luapreprocess.refreezed.com/docs/extra-functionality/#insert-func).

### @@ASSERT(condition, falseMessage)
_This is technically added by [LuaPreprocess](http://luapreprocess.refreezed.com/docs/api/#assert)._

Assert statements are a valuable debugging tool during development. However they come with a performance cost, so you typically don't want to include them in production. 

Lua however doesn't have a way to compile out the native `assert()` function - this is where `@@ASSERT` comes in.

Replace the native `assert()` function with `@@ASSERT` and they will only be included if `assert` is set to `true` in your build config.

### @@IMPORT(path)
Playdate and Love2d handle including files differently: Playdate uses `import()` and Love2d uses `require()`.

The solution in Playbit is the `@@IMPORT` macro which will resolve to the correct include function at build-time. 

Usage is simple, normally where you'd use a platform specific include function, use `@@IMPORT` instead:
```lua
@@IMPORT("CoreLibs/graphics")
```

## Preprocessor flags

### PLAYDATE

Evaluates to `true` when `platform` in your build script is set to `playdate`. Use this to write metaprogram statements for code that should only be included in Playdate builds.

### LOVE2D

Evaluates to `true` when `platform` in your build script is set to `love2d`. Use this to write metaprogram statements for code that should only be included in Love2d builds.

### DEBUG

Evaluates to `true` when `debug` in your build script is set to `true`. Use this to write metaprogram statements for code that should only included in debug builds. Useful for removing debugging or development tools from release builds.

<!-- TODO: meta programming? -->

