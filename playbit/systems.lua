local components = require("playbit.components")
local graphics = require("playbit.graphics")

local System = {}

System.Name = {
  name = "name",
  components = { components.Name.name },
}

System.TextureRenderer = {
  name = "texture-renderer",
  components = { components.Texture.name },
  render = function(scene, entities)
    
  end
}

System.ShapeRenderer = {
  name = "shape-renderer",
  components = { components.Shape.name, components.Transform.name },
  render = function(scene, entities)
    for i = 1, #entities, 1 do
      local shape = scene:getComponent(entities[i], "shape")
      local transform = scene:getComponent(entities[i], "transform")
      graphics.setColor(shape.color)
      if shape.type == "circle" then
        graphics.circle(transform.x + shape.x, transform.y + shape.y, shape.radius, shape.isFilled)
      elseif shape.type == "rectangle" then
        graphics.rectangle(transform.x + shape.x, transform.y + shape.y, shape.width, shape.height, shape.isFilled)
      end
    end
  end
}

return System