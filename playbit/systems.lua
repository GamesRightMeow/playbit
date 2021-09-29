local components = require("playbit.components")

local System = {}

System.NameManager = {
  name = "name",
  components = { components.Name.name },
  update = function(entities)

  end
}

System.RenderManager = {
  name = "render",
  components = { components.Transform.name, components.Graphic.name },
  render = function(entities)
    
  end
}

return System