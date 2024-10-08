# Macros

To learn more about macro functions, see [Core Concepts](core-concepts.md#macro-functions).

## Assert
`@@ASSERT(condition, falseMessage)`

Assert statements are a valuable debugging tool during development. However they come with a performance cost, so you typically don't want to include them in production. 

Lua however doesn't have a way to compile out the native `assert()` function - this is where `@@ASSERT` comes in. Replace the native `assert()` function with `@@ASSERT` and they will only be included if `assert` is set to `true` in your build config.

## Log
`@@LOG(message)`

Persistent print statements are useful for development, but come with a performance cost. Use the log macro when you want print statements when the [debug flag](build-scripts.md#debug) is enabled.

## Import
`@@IMPORT(path)`

As an alternative to the `import()` shim, Playbit also provides the `@@IMPORT` macro which will resolve to the correct include function at build-time. This is slightly more efficient for Love2d builds since the path is evaluated at build-time instead of runtime. 

Under most circumstances you won't need to use this method, but is provided for edge-cases.

Usage is simple, normally where you'd use a platform specific include function, use `@@IMPORT` instead:
```lua
@@IMPORT("CoreLibs/graphics")
```

## Add your own
To add your own macros, see [Macros in LuaPreprocess](https://github.com/GamesRightMeow/LuaPreprocess/blob/master/docs/extra-functionality.md#insert).