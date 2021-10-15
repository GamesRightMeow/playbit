local components = require("playbit.components")
local graphics = require("playbit.graphics")
local graphicRenderer = require("playbit.systems.graphic-renderer")

local System = {}

System.Name = {
  name = "name",
  components = { components.Name.name },
}

-- TODO: this whole file should be removed in favor of dedicated system files
System.GraphicRenderer = graphicRenderer

return System