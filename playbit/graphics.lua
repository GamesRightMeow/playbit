!if LOVE2D then
playbit = playbit or {}
local module = {}
playbit.graphics = module

-- #b0aea7
module.COLOR_WHITE = { 176 / 255, 174 / 255, 167 / 255, 1 }
-- #312f28
module.COLOR_BLACK = { 49 / 255, 47 / 255, 40 / 255, 1 }

module.colorWhite = module.COLOR_WHITE
module.colorBlack = module.COLOR_BLACK
module.shader = love.graphics.newShader("playdate/shader")
module.drawOffset = { x = 0, y = 0}
module.drawColorIndex = 1
module.drawColor = module.colorWhite
module.backgroundColorIndex = 0
module.backgroundColor = module.colorBlack
module.activeFont = {}
module.drawMode = "copy"
module.canvas = love.graphics.newCanvas()
module.contextStack = {}
-- shared quad to reduce gc
module.quad = love.graphics.newQuad(0, 0, 1, 1, 1, 1)
module.lastClearColor = module.colorWhite
module.drawPattern = {0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00}

local canvasScale = 1
local canvasWidth = 400
local canvasHeight = 240
local canvasX = 0
local canvasY = 0
local windowWidth = 400
local windowHeight = 240
local fullscreen = false

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

--- Sets the colors used when drawing graphics.
---@param white table An array of 4 values that correspond to RGBA that range from 0 to 1.
---@param black table An array of 4 values that correspond to RGBA that range from 0 to 1.
function module.setColors(white, black)
  if white == nil then
    white = module.COLOR_WHITE
  end
  if black == nil then
    black = module.COLOR_BLACK
  end
  
  module.colorWhite = white
  module.colorBlack = black
  module.shader:send("white", white)
  module.shader:send("black", black)

  if module.backgroundColorIndex == 1 then
    module.backgroundColor = module.colorWhite
  else
    module.backgroundColor = module.colorBlack
  end

  if module.drawColorIndex == 1 then
    module.drawColor = module.colorWhite
  else
    module.drawColor = module.colorBlack
  end
end

function module.updateContext()
  if #module.contextStack == 0 then
    return
  end

  local activeContext = module.contextStack[#module.contextStack]

  -- love2d doesn't allow calling newImageData() when canvas is active
  love.graphics.setCanvas()
  local imageData = activeContext._canvas:newImageData()
  love.graphics.setCanvas(activeContext._canvas)

  -- update image
  activeContext.data:replacePixels(imageData)
end
!end