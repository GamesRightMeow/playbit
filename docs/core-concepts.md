# Core concepts

## Lua preprocessing

Playbit introduces a [preprocessing](https://en.wikipedia.org/wiki/Preprocessor) step to the build process. During this step, [metaprograms](#metaprogramming) written in your Lua code are evaluated which generate new versions of your Lua scripts. These new scripts are then passed to the Playdate compiler to generate the final playable build of your game.

Note: Lua preprocessing is not directly implemented in Playbit; this functionality is added by the  [LuaPreprocess](http://refreezed.com/luapreprocess) submodule.

## Metaprogramming
From [Wikipedia](https://en.wikipedia.org/wiki/Metaprogramming):
> Metaprogramming is a programming technique in which computer programs have the ability to treat other programs as their data. It means that a program can be designed to read, generate, analyze or transform other programs, and even modify itself while running.

For more information on how to metaprogram, see [How to metaprogram](http://refreezed.com/luapreprocess/docs/#how-to-metaprogram).

## Macro functions
Macro functions are [metaprograms](#metaprogramming) embedded in your Lua files that generate Lua code at runtime. This is useful if you have code you wish to reuse logic in multiple places, but don't want to incur the performance cost of calling a function.

For example, instead of:
```lua
function calculateCost(a, b)
    return (a + 10) + (b * 0.10)
end

function playdate.update()
    local cost1 = calculateCost(10, 100)
    local cost2 = calculateCost(20, 1)
end
```

You could use:
```lua
!(
function calculateCost(a, b)
    return "("..a.." + 10) + ("..b.." * 0.10)"
end
)

function playdate.update()
    local cost1 = @@calculateCost(10, 100)
    local cost2 = @@calculateCost(20, 1)
end
```

Which when compiled, would result in:
```lua
function playdate.update()
    local cost1 = (10 + 10) + (100 * 0.10)
    local cost2 = (20 + 10) + (1 * 0.10)
end
```

For more information on how to write macro functions, see [How to metaprogram](http://refreezed.com/luapreprocess/docs/#how-to-metaprogram).

For a list of macro functions added by Playbit, see [Macro functions](macro-functions.md).

## Inserts

An [insert](http://refreezed.com/luapreprocess/docs/extra-functionality/#insert) is a [macro function](#macro-functions) that you can use to insert Lua code from _another file_. This is how [Playbit's header](#playbit-header) is injected into your game.

<!-- TODO: what's a more useful/practical example? -->
For example:
```lua
-- debugstats.lua
playdate.graphics.drawText(x, 0, 8)
playdate.graphics.drawText(y, 0, 16)
```

```lua
-- main.lua
local x = 0
local y = 0
function playdate.update()
    if playdate.buttonJustPressed("up") then
        y = y - 1
    elseif playdate.buttonJustPressed("down") then
        y = y + 1
    elseif playdate.buttonJustPressed("left") then
        x = x - 1
    elseif playdate.buttonJustPressed("right") then
        x = x + 1
    end
    @@"debugstats.lua"
end
```

## Preprocessor flags
Preprocessor flags are boolean variables that can be used in [macro functions](#macro-functions) to conditionally include (or exclude) blocks of code. For example:

```lua
!if PLAYDATE then
    print("running on playdate!")
!elseif LOVE2D then
    print("running in love2d!"
!end
```

For a list of preprocessor flags added by Playbit, see [Preprocessor flags](preprocessor-flags.md).

## Build scripts
A _build script_ is a Lua script that you run to build your project for a particular platform or configuration. 

For more information, see the [Build Scripts](build-scripts.md)

## Including files via import() vs require()
The Playdate SDK adds the [import function](https://sdk.play.date/Inside%20Playdate.html#_structuring_your_project) for including files. This is not a native function in Lua, so this is not supported in Love2d.

To address this, Playbit defines an `import()` shim in the [header](core-concepts.md#playbit-header) when running under Love2d. Under the hood, this simply calls `require()` with the corrected path.

## Playbit header
The file [header.lua](../header.lua), referred to as _the header_, contains boiler plate code that allows your Playdate code to run under Love2d. The header is added to the top of your project's `main.lua` with a [LuaPreprocess insert macro](#inserts).