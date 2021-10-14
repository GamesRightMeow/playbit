local components = require("playbit.components")
local graphics = require("playbit.graphics")

local System = {}

System.Name = {
  name = "name",
  components = { components.Name.name },
}

local imageCache = {}
local function getImage(path)
  local cachedImage = imageCache[path]
  if cachedImage then
    -- pull from cache if exists
    return cachedImage
  end

  -- otherwise generate new image and cache it
  local img = love.graphics.newImage(path)
  imageCache[path] = img
  return img
end

System.SpritesheetRenderer = {
  name = "spritesheet-renderer",
  components = { components.Spritesheet.name, components.Transform.name, components.Graphic.name },
  render = function(scene, entities)
    for i = 1, #entities, 1 do
      local sprite = scene:getComponent(entities[i], "spritesheet")
      local graphic = scene:getComponent(entities[i], "graphic")
      local transform = scene:getComponent(entities[i], "transform")
      local x = scene.camera.x * graphic.scrollX + transform.x + graphic.x
      local y = scene.camera.y * graphic.scrollY + transform.y + graphic.y

      -- force integers so that graphics arent rendered at subpixels
      x = math.floor(x)
      y = math.floor(y)
      
      local image = getImage(sprite.path)

      -- TODO: should quad creation be cached?
      local totalRows = (image:getWidth() / sprite.width)
      local row = math.floor(sprite.index / totalRows)
      local column = sprite.index % totalRows
      local quad = love.graphics.newQuad(
        column * sprite.width, row * sprite.height, 
        sprite.width, sprite.height, 
        image:getWidth(), image:getHeight()
      )

      -- must set color here to ensure its not tinted
      love.graphics.setColor(1,1,1,1)

      love.graphics.draw(
        image,
        quad,
        x, y, 
        graphic.rotation, 
        graphic.scaleX, graphic.scaleY,
        graphic.originX, graphic.originY
      )
    end
  end
}

System.SpriteRenderer = {
  name = "sprite-renderer",
  components = { components.Sprite.name, components.Transform.name, components.Graphic.name },
  render = function(scene, entities)
    for i = 1, #entities, 1 do
      local sprite = scene:getComponent(entities[i], "sprite")
      local graphic = scene:getComponent(entities[i], "graphic")
      local transform = scene:getComponent(entities[i], "transform")
      local x = scene.camera.x * graphic.scrollX + transform.x + graphic.x
      local y = scene.camera.y * graphic.scrollY + transform.y + graphic.y

      -- force integers so that graphics arent rendered at subpixels
      x = math.floor(x)
      y = math.floor(y)
      
      local image = getImage(sprite.path)

      if sprite.quad == nil then
        sprite.quad = love.graphics.newQuad(
          sprite.x, sprite.y, 
          sprite.width, sprite.height, 
          image:getWidth(), image:getHeight()
        )
      end

      -- must set color here to ensure its not tinted
      love.graphics.setColor(1,1,1,1)

      love.graphics.draw(
        image,
        sprite.quad,
        x, y, 
        graphic.rotation, 
        graphic.scaleX, graphic.scaleY,
        graphic.originX, graphic.originY
      )
    end
  end
}

System.TextureRenderer = {
  name = "texture-renderer",
  components = { components.Texture.name, components.Transform.name, components.Graphic.name },
  imageCache = {},
  render = function(scene, entities)
    for i = 1, #entities, 1 do
      local texture = scene:getComponent(entities[i], "texture")
      local graphic = scene:getComponent(entities[i], "graphic")
      local transform = scene:getComponent(entities[i], "transform")
      local x = scene.camera.x * graphic.scrollX + transform.x + graphic.x
      local y = scene.camera.y * graphic.scrollY + transform.y + graphic.y

      -- force integers so that graphics arent rendered at subpixels
      x = math.floor(x)
      y = math.floor(y)
      
      -- must set color here to ensure its not tinted
      love.graphics.setColor(1,1,1,1)

      love.graphics.draw(
        getImage(texture.path), 
        x, y, 
        graphic.rotation, 
        graphic.scaleX, graphic.scaleY,
        graphic.originX, graphic.originY
      )
    end
  end
}

System.ShapeRenderer = {
  name = "shape-renderer",
  components = { components.Shape.name, components.Transform.name, components.Graphic.name },
  render = function(scene, entities)
    for i = 1, #entities, 1 do
      local shape = scene:getComponent(entities[i], "shape")
      local graphic = scene:getComponent(entities[i], "graphic")
      local transform = scene:getComponent(entities[i], "transform")
      graphics.setColor(shape.color)

      local x = scene.camera.x * graphic.scrollX + transform.x + graphic.x
      local y = scene.camera.y * graphic.scrollY + transform.y + graphic.y

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