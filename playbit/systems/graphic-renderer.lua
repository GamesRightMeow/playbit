local components = require("playbit.components")
local graphics = require("playbit.graphics")

local GraphicRenderer = {}

-- TODO: this is probably safe to share between scenes, but seems wrong? maybe store in each scene?
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

GraphicRenderer.name = "graphic-renderer"
GraphicRenderer.components = { components.Transform.name, components.Graphic.name }

function GraphicRenderer.render(scene, entities)
  -- generate layer buckets
  -- TODO: this happens every frame which will get expensive with lots of entities
  local layers = {}
  local layerIndexes = {}
  for i = 1, #entities, 1 do
    local entityId = entities[i]
    local graphic = scene:getComponent(entities[i], "graphic")
    if layers[graphic.layer] == nil then
      layers[graphic.layer] = {}
      table.insert(layerIndexes, graphic.layer)
    end
    table.insert(layers[graphic.layer], entityId)
  end

  table.sort(layerIndexes)

  -- render sorted entities
  for l = 1, #layerIndexes, 1 do
    local layerIndex = layerIndexes[l]
    
    for e = 1, #layers[layerIndex], 1 do
      local entityId = layers[layerIndex][e];
      local graphic = scene:getComponent(entityId, "graphic")
      if not graphic.visible then
        goto continue
      end

      local transform = scene:getComponent(entityId, "transform")

      -- calculate render position
      local x = scene.camera.x * graphic.scrollX + transform.x + graphic.x
      local y = scene.camera.y * graphic.scrollY + transform.y + graphic.y

      local spritesheet = scene:getComponent(entityId, "spritesheet")
      local sprite = scene:getComponent(entityId, "sprite")
      local texture = scene:getComponent(entityId, "texture")
      local shape = scene:getComponent(entityId, "shape")
      if spritesheet then
        -- always render pure white so its not tinted
        love.graphics.setColor(1, 1, 1, 1)

        local image = getImage(spritesheet.path)

        -- TODO: should quad creation be cached? this will change based on sheet index
        local totalRows = (image:getWidth() / spritesheet.width)
        local row = math.floor(spritesheet.index / totalRows)
        local column = spritesheet.index % totalRows
        local quad = love.graphics.newQuad(
          column * spritesheet.width, row * spritesheet.height, 
          spritesheet.width, spritesheet.height, 
          image:getWidth(), image:getHeight()
        )

        love.graphics.draw(
          image,
          quad,
          x, y, 
          graphic.rotation, 
          graphic.scaleX, graphic.scaleY,
          graphic.originX, graphic.originY
        )
      elseif sprite then
        -- always render pure white so its not tinted
        love.graphics.setColor(1, 1, 1, 1)

        local image = getImage(sprite.path)

        if sprite.quad == nil then
          sprite.quad = love.graphics.newQuad(
            sprite.x, sprite.y, 
            sprite.width, sprite.height, 
            image:getWidth(), image:getHeight()
          )
        end

        love.graphics.draw(
          image,
          sprite.quad,
          x, y, 
          graphic.rotation, 
          graphic.scaleX, graphic.scaleY,
          graphic.originX, graphic.originY
        )
      elseif texture then
        -- always render pure white so its not tinted
        love.graphics.setColor(1, 1, 1, 1)

        local image = getImage(texture.path)

        love.graphics.draw(
          image, 
          x, y, 
          graphic.rotation, 
          graphic.scaleX, graphic.scaleY,
          graphic.originX, graphic.originY
        )
      elseif shape then
        -- set color based on property
        graphics.setColor(shape.color)

        if shape.type == "circle" then
          graphics.circle(x, y, shape.radius, shape.isFilled)
        elseif shape.type == "rectangle" then
          graphics.rectangle(x, y, shape.width, shape.height, shape.isFilled, graphic.rotation)
        end
      end
      ::continue::
    end
  end
end

return GraphicRenderer
