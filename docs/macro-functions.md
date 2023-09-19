<!-- FIXME: relink incoming -->
# Macros

## Assert
`@@ASSERT(condition, falseMessage)`

Assert statements are a valuable debugging tool during development. However they come with a performance cost, so you typically don't want to include them in production. 

Lua however doesn't have a way to compile out the native `assert()` function - this is where `@@ASSERT` comes in.

Replace the native `assert()` function with `@@ASSERT` and they will only be included if `assert` is set to `true` in your build config.

## Import
`@@IMPORT(path)`

Playdate and Love2d handle including files differently: Playdate uses `import()` and Love2d uses `require()`.

The solution in Playbit is the `@@IMPORT` macro which will resolve to the correct include function at build-time. 

Usage is simple, normally where you'd use a platform specific include function, use `@@IMPORT` instead:
```lua
@@IMPORT("CoreLibs/graphics")
```

## Add your own
To add your own macros, see [Macros in LuaPreprocess](http://luapreprocess.refreezed.com/docs/extra-functionality/#insert-func).