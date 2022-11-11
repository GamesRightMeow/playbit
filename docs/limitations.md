# Playbit limitations
The following are fundamental limitations due to the nature of this framework.

## Intellisense syntax errors
[Metaprogram statements](http://luapreprocess.refreezed.com/docs/#how-to-metaprogram) are not considered valid by intellisense plugins/extensions. This is because they aren't _technically_ valid Lua syntax with the leading exclamation mark. LuaPreprocess strips the exclamation mark before executing the metaprogram.

Depending on your IDE/plugin, you can try to add metaprogram statements as an exception or simply ignore relevant warnings.

## Line numbers are wrong in error messages
Line numbers in error messages may not match up to your _original_ source code, particularly if you're writing everything inside of `main.lua`. This is because lines of source code are added/removed during the preprocess step. 

However the line numbers in error messages will line up to the Lua source that is _created from the preprocess step_!

If you're using the [Playbit template](https://github.com/GamesRightMeow/playbit-template), these folders are called `_love2d` for Love2d and `_pdx` for Playdate. Keep in mind that any modifications to files in these folders will be overwritten the next time you run the build script.

## No assignment operators
The Playdate SDK adds [additional assignment operators](https://sdk.play.date/Inside%20Playdate.html#additional-assignment-operators) for your convenience. Unfortunately these are not supported in Love2D, so you'll need to use the plain assignment operator.

For example, instead of `myVar += 1` use `myVar = myVar + 1`.

## Using import() vs require()
The Playdate SDK adds the [import function](https://sdk.play.date/Inside%20Playdate.html#_structuring_your_project) for including files. This is not supported in Love2d.

You'll need to replace calls to `import()` with the Playbit macro `@@IMPORT()`.

For example, instead of `import("CoreLibs/graphics")` use `@@IMPORT("CoreLibs/graphics")`.

## Using the Love2D API directly
Playbit reimplements the Playdate API in Love2D, not the other way around! As such, you can't use the Love2D API on Playdate.

However you can, use the Love2D API on desktop. You just need to wrap calls in metaprogram if-statements:
```lua
!if LOVE2D then
love.window.setTitle("My Game")
!end
```