# Introduction to file processors
File processors are Lua functions that handle processing files at build-time with a specific extension. A file processor can simply copy a file or run external tools to process export a game-ready file.

## Built-in file processors

Playbit includes out-of-the-box file processors for common file types:

- [Default/fallback](#defaultfallback) (any file type)
- [Aseprite](#aseprite) (.aseprite)
- [Caps fonts](#caps-fonts) (.fnt and paired .png)
- [Lua](#lua) (.lua)
- [Wave](#wave) (.wav)

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
      path = "C:/Program Files/Aseprite/Aseprite.exe",
      scale = 2,
      ignoredLayers = {
        "bg",
        "placeholder",
      },
    }
  }
}
```

Exports [Aseprite](https://www.aseprite.org/) files (.aseprite). Aseprite must be installed for this to work. 

The aseprite executable must either be added to your system path or specified using the **path** variable below.

It has the following options:
- **path:** If set, this path is used to call Aseprite from the command-line instead of relying on your system path. Defaults to `nil`.
- **scale:** Sets the [scale](https://www.aseprite.org/docs/cli/#scale) to export the image at. Defaults to `1.0`.
- **ignoredLayers:** [Hides layers by name](https://www.aseprite.org/docs/cli/#ignore-layer) from the exported image. Defaults to `{}`.

### Caps fonts
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

