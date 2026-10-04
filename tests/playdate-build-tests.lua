local build = require("build")

--[[ Create output folder for playdate images as Playdate SDK
will throw errors if it doesn't exist ]]--
local fs = require("tools.filesystem")
local p = fs.sanitizePath("tests/src/images/expected/")
fs.deleteDirectory(p)
fs.createFolderIfNeeded(p)

build.build({ 
  assert = true,
  debug = true,
  platform = "playdate",
  output = "_tests_pdx",
  clearBuildFolder = true,
  fileProcessors = {
    lua = build.luaProcessor,
    wav = build.waveProcessor,
    aseprite = build.skipFile,
  },
  files = {
    -- essential playbit files for playdate
    { "playbit", "playbit" },
    -- project
    { "fonts/", "fonts" },
    { "tests/src/images/", "images/" },
    { "tests/src/sounds/", "sounds/" },
    { "tests/src/data/", "data/" },
    { "tests/src/main.lua", "main.lua" },
    { "tests/src/pbassert.lua", "pbassert.lua" },
    { "tests/src/suites", "suites/" },
    { "tests/src/metadata.json", "pdxinfo",
      {
        json = { build.pdxinfoProcessor, { incrementBuildNumber = false } }
      }
    }
  },
})