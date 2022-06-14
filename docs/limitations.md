# Playbit limitations
The following are fundamental limitations due to the nature of this framework.

## Intellisense syntax error
[Metaprogram statements](http://luapreprocess.refreezed.com/docs/#how-to-metaprogram) are not considered valid by intellisense plugins/extensions. This is because they aren't _technically_ valid Lua syntax with the leading exclamation mark. LuaPreprocess strips the exclamation mark before executing the metaprogram.

Depending on your IDE/plugin, you can try to add metaprogram statements as an exception or simply ignore relevant warnings.

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