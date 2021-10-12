local components = require("playbit.components")
local graphics = require("playbit.graphics")

local System = {}

System.Name = {
  name = "name",
  components = { components.Name.name },
}

System.TextureRenderer = {
  name = "texture-renderer",
  components = { components.Texture.name, components.Transform.name },
  imageCache = {},
  render = function(scene, entities)
    for i = 1, #entities, 1 do
      local texture = scene:getComponent(entities[i], "texture")
      local transform = scene:getComponent(entities[i], "transform")
      local x = scene.camera.x * texture.scrollX + transform.x + texture.x
      local y = scene.camera.y * texture.scrollY + transform.y + texture.y

      -- force integers so that graphics arent rendered at subpixels
      x = math.floor(x)
      y = math.floor(y)
      
      -- get drawable once
      if texture.drawable == nil then
        if System.TextureRenderer.imageCache[texture.path] then
          -- pull from cache if exists
          texture.drawable = System.TextureRenderer.imageCache[texture.path]
        else
          -- otherwise generate new image and cache it
          local img = love.graphics.newImage(texture.path)
          System.TextureRenderer.imageCache[texture.path] = img
          texture.drawable = img
        end
      end
      
      graphics.draw(texture.drawable, 
        x, y, 
        texture.rotation, 
        texture.scaleX, texture.scaleY,
        texture.originX, texture.originY
      )
    end
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

      local x = scene.camera.x * shape.scrollX + transform.x + shape.x
      local y = scene.camera.y * shape.scrollY + transform.y + shape.y

      -- force integers so that graphics arent rendered at subpixels
      x = math.floor(x)
      y = math.floor(y)

      if shape.type == "circle" then
        graphics.circle(x, y, shape.radius, shape.isFilled)
      elseif shape.type == "rectangle" then
        graphics.rectangle(x, y, shape.width, shape.height, shape.isFilled)
      end
    end
  end
}

return System