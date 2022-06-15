# Build scripts
A _build script_ is a Lua script that you run to build your project. For example:

```lua
-- include the main build script
local build = require("playbit.build")

build.build({ 
  assert = true,
  debug = true,
  platform = "love2d",
  output = "_game",
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

## Introduction to file processors
File processors are functions that handle files with a specific extension. There are several built in file processors, including a fallback file processor that simply copies the file.

### Default/fallback
```lua
fileProcessors = {
  txt = build.defaultProcessor,
}
```

The default processor simply copies a file from the input path to the output path.

You can manually assign an extension to the default processor. However if a processor is not found, the build system will always fallback to this processor.

### Aseprite
```lua
fileProcessors = {
  aseprite = {
    build.asepriteProcessor,
    {
      scale = 2,
      ignoredLayers = {
        "bg",
        "placeholder",
      },
    }
  }
}
```

Exports [Aseprite](https://www.aseprite.org/) files (.aseprite). Aseprite must be installed and added to your path.

It has the following options:
- **scale:** Sets the [scale](https://www.aseprite.org/docs/cli/#scale) to export the image at. Defaults to `1.0`.
- **ignoredLayers:** [Hides layers by name](https://www.aseprite.org/docs/cli/#ignore-layer) from the exported image. Defaults to `{}`.

### Fnt
```lua
fileProcessors = {
  fnt = build.fntProcessor,
}
```

Converts [Caps](https://play.date/caps/) fonts to [BMFonts](https://www.angelcode.com/products/bmfont/) for use in Love2d.

### Lua
```lua
fileProcessors = {
  lua = build.luaProcessor,
}
```

Uses [LuaPreprocess](https://github.com/ReFreezed/LuaPreprocess) to run your metaprogram and strip platform-dependent code.

### Wave
```lua
fileProcessors = {
  wav = build.waveProcessor,
}
```

Converts .wav files to the [Playdate-supported IMA ADPCM](https://sdk.play.date/1.11.1/Inside%20Playdate.html#M-sound) format. [FFmpeg](https://www.ffmpeg.org/) must be installed and added to your path.

### Custom

You can also create your own file processor, simply by defining a function in a build script.

```lua
local build = require("playbit.build")
local fs = require("playbit.tools.filesystem")

-- appends "hello world" to the end of text files
local function textProcessor(input, output, options)
  local inputFile = io.open(input, "rb")
  local contents = inputFile:read("a")
  inputFile:close()

  contents = contents.."\nhello world!"

  fs.createFolderIfNeeded(output)
  local outputFile = io.open(output, "w+b")
  outputFile:write(contents)
  outputFile:close()
end

build.build({ 
  fileProcessors = {
    txt = txtProcessor,
  },
})
```

File processor functions require three parameters:
- **input:** a string of the absolute file path to the source file.
- **output:** a string of the absolute file path to the destination file.
- **options:** an object that contains key-value pairs that contains processor-specific settings.

## Settings

### assert
A boolean value where a value of `false` compiles out `@@ASSERT` macros.

### debug
Sets the value of the [DEBUG preprocessor flag](core-concepts.md#debug). A value of `true` indicates the build is a non-production build. Currently only affects [perf.lua](/playbit/perf.lua) but can be used to control what builds your own developer tools are enabled in.

### env
An array of strings that represent boolean flags. If a flag is in this list, it has a value of `true`. Use this to add custom preprocessor flags.

### fileProcessors
An object that defines the _global_ [file processors](#introduction-to-file-processors).

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
2. A 3-element array where the first two elements are as above, but the third element is a fileProcessor object. The build system will look for a processor here first, before checking the [global processors](#fileprocessors). This is useful when you need to define a specific file processor for specific files/folders. 
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

