# Build scripts
A _build script_ is a Lua script that you run to build your project for a particular platform or configuration. For example:

```lua
-- include the main build script
local build = require("playbit.build")

build.build({ 
  assert = true,
  debug = true,
  platform = "love2d",
  output = "_game",
  clearBuildFolder = true,
  fileProcessors = {
    lua = build.luaProcessor,
    fnt = build.fntProcessor,
    aseprite = {
      build.asepriteProcessor,
      {
        ignoredLayers = {
          "bg",
          "placeholder",
        },
      }
    }
  },
  files = {
    -- essential playbit files for love2d
    { "playbit/conf.lua", "conf.lua" },
    { "playbit/playbit", "playbit" },
    { "playbit/playdate", "playdate" },
    { "playbit/json/json.lua", "json/json.lua" },
    -- main game script
    { "src/main.lua", "main.lua" },
    -- other game specific folders
    { "src/scripts", "scripts" },
    { "src/fonts", "fonts" },
    { "src/map", "map" },
    { "src/textures", "textures" },
  },
})
```

Then run via CLI with `lua mybuildscript.lua`

## Settings

### assert
A boolean value where a value of `false` compiles out `@@ASSERT` macros.

### clearBuildFolder

A boolean value where a value of `true` causes the build folder to be deleted (if it exists) before building.

Set this to `false` for custom build scripts where you want to do a smaller rebuild i.e. only update level files.

### debug
Sets the value of the [DEBUG preprocessor flag](core-concepts.md#debug). A value of `true` indicates the build is a non-production build. Currently only affects [perf.lua](/playbit/perf.lua) but can be used to control what builds your own developer tools are enabled in.

### env
An array of strings that represent boolean flags. If a flag is in this list, it has a value of `true`. Use this to add custom preprocessor flags.

### fileProcessors
An object that defines the _global_ [file processors](file-processors.md).

Each key in the list represents the extension you want to associate the processor with e.g. for `.lua` files you should use `lua` as the key.

The value can be a file processor function:

```lua
fileProcessors = {
  aseprite = build.asepriteProcessor,
}
```

Or an array, where the first element is the file processor function and the second element is a settings object:

```lua
fileProcessors = {
  aseprite = {
    build.asepriteProcessor,
    {
      ignoredLayers = {
        "bg",
        "placeholder",
      },
    }
  }
}
```

### files
An array of arrays that define the files that will be processed during the build. The way files are processed is determined by the [file processors](#fileprocessors) you've defined.

You can specify files or folders. All paths should be relative to your project folder.

```lua
files = {
  -- essential playbit files for love2d
  { "playbit/conf.lua", "conf.lua" },
  { "playbit/playbit", "playbit" },
  { "playbit/playdate", "playdate" },
  { "playbit/json/json.lua", "json/json.lua" },
  -- game specific folders
  -- etc
}
```

Each item-array can either be:

1. A 2-element array where the first element is the path to the source file/folder and the second element is the destination file/folder.
    ```lua
    files = {
      { "src/textures", "textures" }
    }
    ``` 
2. A 3-element array where the first two elements are as above, but the third element is a fileProcessor object. The build system will look for a file processor here first, before checking the [global file processors](#fileprocessors). This is useful when you need to define a specific file processor for specific files/folders. 
    ```lua
    files = {
      { "src/textures/items", "textures/items" },
      { "src/textures/characters", "textures/characters", 
        {
          aseprite = { build.asepriteProcessor, { scale = 2 } }
        }
      }
    }
    ```

### output
The output path your post-processed project will be saved to. This path should be relative to your project folder.

### platform
A string value that can be:
- `playdate`: builds your project for Playdate
- `love2d`: builds your project for Love2D

