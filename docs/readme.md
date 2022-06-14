# Playbit
Playbit is framework for creating cross-platform Playdate games from a single Lua codebase. To accomplish this, it has two key components
* A reimplemention the Playdate API in Love2D.
* A build system that utilizes a [preprocessor](https://github.com/ReFreezed/LuaPreprocess/) to strip/inject platform dependent code.

**⚠ IMPORTANT:** This project is in active development and has not reached a stable 1.0 release yet. Use in a production environment at your own risk. 

## Current Features
* Partial reimplementation of Playdate API in Love2D
* Custom build scripts
* Custom preprocessor flags
* Export [Aseprite (.aseprite)](https://www.aseprite.org/) files at build-time
* Convert [Caps](https://play.date/caps/) fonts to [BMFonts](https://www.angelcode.com/products/bmfont/) at build-time
* Custom build-time file processors
* Macro support (via LuaPreprocess's [macros](http://luapreprocess.refreezed.com/docs/extra-functionality/#insert-func))
* Compile asserts out for release builds (via LuaPreprocess's [ASSERT() macro](http://luapreprocess.refreezed.com/docs/api/#assert))

## Known issues/limitations
Listed below are key limitations; for a full list see  open [issues](). If you'd like to help improve/solve/fix an issue, please see the [Contributing guide](contributing.md).

<!-- TODO: link to Github issues when opened -->
* Lua intellisense plugins/extensions incorrectly flags [metaprogram statements](http://luapreprocess.refreezed.com/docs/#how-to-metaprogram)
* Playdate API is not fully reimplemented
* Build script does not support Mac
* Build-time creation of [.love-file and platform executables](https://love2d.org/wiki/Game_Distribution)
* Fonts
  * Only ASCII characters are supported
  * The glyph atlas must have 16 glyphs per row

## Documentation
If you're new, see [Getting Started](getting-started.md).

For documentation on installation, usage, and other features see the [docs folder](/docs/).