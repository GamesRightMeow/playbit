# Build scripts
<!-- TODO: document settings, gotchas, example vscode tasks -->
## Settings

### assert
A boolean value where a value of `false` compiles out `@@ASSERT` macros.

### debug
Sets the value of the [DEBUG flag](core-concepts.md#debug). A value of `true` indicates the build is a non-production build. Currently only affects [perf.lua](/playbit/perf.lua) but can be used to control what builds your own developer tools are enabled in.

### env
An array of strings that represent boolean flags. If a flag is in this list, it has a value of `true`.

### fileProcessors
<!-- TODO: -->

### folders
<!-- TODO: -->

### output
The output path your post-processed project will be saved to. This path should be relative to your project folder.

### platform
A string value that can be:
- `playdate`: builds your project for Playdate
- `love2d`: builds your project for Love2D

## File processors
<!-- TODO: -->
### Default processor

### Aseprite

### Fnt

### Lua

### Wave