local build = require("build")

build.build({ 
  assert = true,
  debug = true,
  platform = "love2d",
  output = "_tests_love2d",
  clearBuildFolder = true,
  fileProcessors = {
    lua = build.luaProcessor,
    fnt = build.fntProcessor,
    aseprite = build.asepriteProcessor,
  },
  files = {
    -- essential playbit files for love2d
    { "conf.lua", "conf.lua" },
    { "playbit", "playbit" },
    { "playdate", "playdate" },
    { "json/json.lua", "json/json.lua" },
    -- project
    { "fonts/", "fonts" },
    { "tests/src/images/", "images/" },
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