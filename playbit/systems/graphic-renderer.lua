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
GraphicRenderer.components = { pb.components.Transform.name, pb.components.Graphic.name }

--! if LOVE2D then
local playbitShader = love.graphics.newShader[[
extern float WhiteFactor;

vec4 effect(vec4 vcolor, Image tex, vec2 texcoord, vec2 pixcoord)
{
    vec4 outputcolor = Texel(tex, texcoord) * vcolor;
    outputcolor.rgb += vec3(WhiteFactor);
    outputcolor.rgb = min(outputcolor.rgb, vec3(0.84313725490196, 0.83137254901961, 0.8));
    return outputcolor;
}
]]
--! end

local function renderSpritesheet(x, y, graphic, spritesheet)
  -- render texture as solid white or not
  playbitShader:send("WhiteFactor", graphic.flash > 0 and 1 or 0)

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
end

local function renderSprite(x, y, graphic, sprite)
  -- render texture as solid white or not
  playbitShader:send("WhiteFactor", graphic.flash > 0 and 1 or 0)

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
end

local function renderTexture(x, y, graphic, texture)
  -- render texture as solid white or not
  playbitShader:send("WhiteFactor", graphic.flash > 0 and 1 or 0)

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
end

local function renderShape(x, y, graphic, shape)
  -- TODO: flash shape?
  playbitShader:send("WhiteFactor", 0)

  -- set color based on property
  pb.graphics.setColor(shape.color)

  if shape.type == "circle" then
    pb.graphics.circle(x, y, shape.radius, shape.isFilled, shape.lineThickness)
  elseif shape.type == "rectangle" then
    pb.graphics.rectangle(x, y, shape.width, shape.height, shape.isFilled, graphic.rotation, shape.lineThickness)
  end
end

local function renderText(x, y, graphic, text)
  -- TODO: flash text?
  playbitShader:send("WhiteFactor", 0)

  -- set color based on property
  pb.graphics.setColor(text.color)

  pb.graphics.text(text.text, x, y, text.align)
end

local function renderParticleSystem(x, y, graphic, particleSystem)
  -- the particle system gets its values set internally
  x = pb.app.scene.camera.x
  y = pb.app.scene.camera.y

  -- TODO: flash particle?
  playbitShader:send("WhiteFactor", 0)

  local image = getImage(particleSystem.path)

  -- always render pure white so its not tinted
  love.graphics.setColor(1, 1, 1, 1)

  if particleSystem.system == nil then
    local system = love.graphics.newParticleSystem(image, particleSystem.maxParticles)
    particleSystem.system = system
  end

	love.graphics.draw(particleSystem.system, x, y)
end

local function renderLine(x, y, graphic, line)
  local pointCount = #line.points
  if pointCount < 2 then
    -- we need at least 2 points to draw a segment
    return
  end

  -- TODO: flash line?
  playbitShader:send("WhiteFactor", 0)

  -- set color based on property
  pb.graphics.setColor(line.color)

  love.graphics.push()

  love.graphics.translate(x, y)
  love.graphics.rotate(graphic.rotation)
  
  for i = 1, #line.points - 1, 1 do
    local point = line.points[i]
    local nextPoint = line.points[i + 1]
    pb.graphics.line(point.x, point.y, nextPoint.x, nextPoint.y, line.lineThickness)
  end

  love.graphics.pop()
end


local renderers = {}
function GraphicRenderer.addRenderer(componentName, renderer)
  pb.debug.assert(renderers[componentName] == nil)
  renderers[componentName] = renderer
end

GraphicRenderer.addRenderer("spritesheet", renderSpritesheet)
GraphicRenderer.addRenderer("sprite", renderSprite)
GraphicRenderer.addRenderer("texture", renderTexture)
GraphicRenderer.addRenderer("shape", renderShape)
GraphicRenderer.addRenderer("text", renderText)
GraphicRenderer.addRenderer("particle-system", renderParticleSystem)
GraphicRenderer.addRenderer("line", renderLine)

function GraphicRenderer.render(scene, entities)
  -- generate layer buckets
  -- TODO: this happens every frame which will get expensive with lots of entities
  local layers = {}
  local layerIndexes = {}
  for i = 1, #entities, 1 do
    local entityId = entities[i]
    local graphic = scene:getComponent(entityId, "graphic")
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

      -- TODO: should this be called every frame?
      love.graphics.setShader(playbitShader)

      -- calculate render position
      local x = transform.x + graphic.x
      local y = transform.y + graphic.y

      -- if in world space, add camera and scroll offsets
      if graphic.worldSpace then
        x = x + scene.camera.x * graphic.scrollX
        y = y + scene.camera.y * graphic.scrollY
      end

      -- TODO: (optimization) cache the component to graphic component so that we don't have to do this look up each time?
      -- TODO: (optimization) get components by ID instead of name
      local renderComponent = nil
      for rendererName, rendererFunc in pairs(renderers) do
        renderComponent = scene:getComponent(entityId, rendererName)
        if renderComponent then
          rendererFunc(x, y, graphic, renderComponent)
          break
        end
      end

      -- reduce flash timer
      if graphic.flash > 0 then
        graphic.flash = math.max(0, graphic.flash - pb.util.deltaTime())
      end

      ::continue::
    end
  end
end

return GraphicRenderer
