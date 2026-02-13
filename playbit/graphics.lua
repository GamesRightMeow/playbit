!if LOVE2D then
playbit = playbit or {}
local module = {}
playbit.graphics = module

module.SCR_WIDTH  = 400
module.SCR_HEIGHT = 240

-- #b0aea7
module.COLOR_WHITE = { 176 / 255, 174 / 255, 167 / 255, 1 }
-- #312f28
module.COLOR_BLACK = { 49 / 255, 47 / 255, 40 / 255, 1 }

module.colorWhite = module.COLOR_WHITE
module.colorBlack = module.COLOR_BLACK

module.shaders =
{
  final   = love.graphics.newShader("playbit/shaders/final.glsl"),
  color   = love.graphics.newShader("playbit/shaders/color.glsl"),
  pattern = love.graphics.newShader("playbit/shaders/pattern.glsl"),
  image   = { }
}

local shader = love.filesystem.read("playbit/shaders/image.glsl")
for i = 0, 9 do
  local src = "#define DRAW_MODE " .. i .. "\n" .. shader
  module.shaders.image[i] = love.graphics.newShader(src)
end

module.shader = love.graphics.newShader("playdate/shader")
module.drawOffset = { x = 0, y = 0}
module.drawColorIndex = 1
module.drawColor = module.colorWhite
module.backgroundColorIndex = 0
module.backgroundColor = module.colorBlack
module.activeFont = {}
module.imageDrawMode = 0
module.drawMode = nil
module.canvas = love.graphics.newCanvas()
module.contextStack = {}
-- shared quad to reduce gc
module.quad = love.graphics.newQuad(0, 0, 1, 1, 1, 1)
module.lastClearColor = module.colorWhite
module.drawPattern = nil
module.lineWidth = 1
module.debugDrawColor = { 1, 0, 0, 0.5 }

local canvasScale = 1
local canvasWidth = module.SCR_WIDTH
local canvasHeight = module.SCR_HEIGHT
local canvasX = 0
local canvasY = 0
local windowWidth = module.SCR_WIDTH
local windowHeight = module.SCR_HEIGHT
local fullscreen = false
local fullscreenType = "desktop"

--- Sets the scale of the canvas.
---@param scale number
function module.setCanvasScale(scale)
  canvasScale = scale
end

---Returns the current scale of the canvas.
---@return number
function module.getCanvasScale()
  return canvasScale
end

--- Sets the canvas size.
---@param width number
---@param height number
function module.setCanvasSize(width, height)
  canvasWidth = width
  canvasHeight = height
end

--- Returns the current canvas size.
---@return integer width
---@return integer height
function module.getCanvasSize()
  return canvasWidth, canvasHeight
end

--- Sets the canvas position within the window.
---@param x any
---@param y any
function module.setCanvasPosition(x, y)
  canvasX = x
  canvasY = y
end

--- Returns the current canvas position within the window.
---@return integer x
---@return integer y
function module.getCanvasPosition()
  return canvasX, canvasY
end

--- Sets the size of the window.
---@param width number
---@param height number
function module.setWindowSize(width, height)
  windowWidth = width
  windowHeight = height
end

--- Returns the current window size.
---@return integer width
---@return integer height
function module.getWindowSize()
  return windowWidth, windowHeight
end

--- Sets fullscreen (true) or window mode (false).
---@param enabled any
function module.setFullscreen(enabled)
  fullscreen = enabled
end

--- Returns if the game is in fullscreen (true) or window mode (false).
---@return boolean
function module.getFullscreen()
  return fullscreen
end

--- Sets the fullscreen type either "desktop" (default) or "exclusive".
--- https://love2d.org/wiki/FullscreenType
---@param type any
function module.setFullscreenType(type)
  fullscreenType = type
end

--- Returns the current fullscreen type.
--- @param type any
--- @return string
function module.getFullscreenType(type)
  return fullscreenType
end

--- Sets the colors used when drawing graphics.
---@param white table An array of 4 values that correspond to RGBA that range from 0 to 1.
---@param black table An array of 4 values that correspond to RGBA that range from 0 to 1.
function module.setColors(white, black)
  module.colorWhite = white or module.COLOR_WHITE
  module.colorBlack = black or module.COLOR_BLACK
end

local function copyAndSwapCanvases()
  local shader = love.graphics.getShader()

  -- create second canvas if needed of the same size.
  if not module.canvas2 then
    local w, h = module.canvas:getWidth(), module.canvas:getHeight()
    module.canvas2 = love.graphics.newCanvas(w, h)
  end

  -- copy original canvas to another one
  love.graphics.push()
  love.graphics.origin()
  love.graphics.setCanvas(module.canvas2)
  love.graphics.setShader()
  love.graphics.draw(module.canvas)
  love.graphics.pop()

  -- swap canvases.
  module.canvas, module.canvas2 = module.canvas2, module.canvas

  -- restore shader and the color
  love.graphics.setShader(shader)
end

local function getShader(mode)
  if mode == "line" then
    return module.shaders.color

  elseif mode == "fill" then
    if module.drawPattern then
      return module.shaders.pattern
    else
      return module.shaders.color
    end

  elseif mode == "image" then
    return module.shaders.image[module.imageDrawMode]
  end
end

function module.setDrawMode(mode)
  if module.drawMode ~= mode then
    module.drawMode = mode
    local shader = getShader(mode)
    -- TODO: we have to do this before every drawing call.
    if shader:hasUniform("canvas") then
      copyAndSwapCanvases()
      shader:send("canvas", module.canvas2)
    end
    love.graphics.setShader(shader)
  end
end
!end
