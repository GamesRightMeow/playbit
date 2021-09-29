local build = require("build")

build.build({ 
  verbose = true,
  output = "_dist\\",
  luaFolders = {
    { "playbit", "playbit" }
  },
  copyFiles = {
    { "example\\main.lua", "_dist\\main.lua" },
    { "example\\conf.lua", "_dist\\conf.lua" },
  },
  runOnSuccess = "love _dist",
})