local build = require("build")

--[[ Create output folder for playdate images as Playdate SDK
will throw errors if it doesn't exist ]]--
local fs = require("tools.filesystem")
fs.createFolderIfNeeded("tests/src/images/expected/")

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
    { "tests/src/main.lua", "main.lua" },
    { "tests/src/suites", "suites/" },
    { "tests/src/metadata.json", "pdxinfo",
      {
        json = { build.pdxinfoProcessor, { incrementBuildNumber = false } }
      }
    }
  },
})