# Playbit limitations
The following are fundamental limitations due to the nature of this framework.

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