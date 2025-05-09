!if LOVE2D then
playbit = playbit or {}
local module = {}
playbit.graphics = module

local screenScale = 1
local screenWidth = 400
local screenHeight = 240
local screenX = 0
local screenY = 0

--- Sets the scale of the screen.
---@param scale number
function module.setScreenScale(scale)
  screenScale = scale
end

---Returns the current scale of the screen.
---@return number
function module.getScreenScale()
  return screenScale
end

--- Sets the window (not screen) size.
---@param width number
---@param height number
function module.setResolution(width, height)
  screenWidth = width
  screenHeight = height
end

--- Returns the current window size.
---@return integer width
---@return integer height
function module.getResolution()
  return screenWidth, screenHeight
end

--- Sets the screen position within the window.
---@param x any
---@param y any
function module.setScreenPosition(x, y)
  screenX = x
  screenY = y
end

--- Returns the current screen position within the window.
---@return integer x
---@return integer y
function module.getScreenPosition()
  return screenX, screenY
end
!end