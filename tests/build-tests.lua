local build = require("build")

build.build({ 
  assert = true,
  debug = true,
  platform = "love2d",
  output = "_tests",
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
    { "tests/src/tests", "tests" },
    { "tests/src/fonts", "fonts" },
    { "tests/src/main.lua", "main.lua" },
  },
})