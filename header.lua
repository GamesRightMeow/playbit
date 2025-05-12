!if LOVE2D then
require("playdate.playdate")
require("playdate.datastore")
require("playdate.string")
require("playdate.metadata")
require("playdate.graphics")
require("playdate.image")
require("playdate.imagetable")
require("playdate.tilemap")
require("playdate.font")
require("playdate.animation")
require("playdate.file")
require("playdate.json")
require("playdate.sound")
require("playdate.easing")
require("playdate.frameTimer")
require("playdate.timer")

require("playbit.graphics")

function import(path)
  if string.match(path, "^CoreLibs/") then
    -- ignore these imports, since the playdate namespace is already reimplemented in the global namespace
    return
  end
  path = string.gsub(path, "/", ".")
  return require(path)
end

local firstFrame = true
local windowWidth, windowHeight = playbit.graphics.getWindowSize()

playdate.graphics._canvas:setFilter("nearest", "nearest")

love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineWidth(1)
love.graphics.setLineStyle("rough")

playdate.graphics.setBackgroundColor(1)
playdate.graphics.setColor(0)

math.randomseed(os.time())

function love.draw()
  -- must be changed at start of frame when canvas is not active
  local newCanvasWidth, newCanvasHeight = playbit.graphics.getCanvasSize()
  local canvasWidth = playdate.graphics._canvas:getWidth()
  local canvasHeight = playdate.graphics._canvas:getHeight()
  if canvasWidth ~= newCanvasWidth or canvasHeight ~= newCanvasHeight then
    playdate.graphics._canvas = love.graphics.newCanvas(newCanvasWidth, newCanvasHeight)
  end

  -- must be changed at start of frame - love2d doesn't allow changing window size with canvas active
  local newWindowWidth, newWindowHeight = playbit.graphics.getWindowSize()
  if windowWidth ~= newWindowWidth or windowHeight ~= newWindowHeight then
    local w, y, flags = love.window.getMode()
    love.window.setMode(newWindowWidth, newWindowHeight, flags)
    windowWidth = newWindowWidth
    windowHeight = newWindowHeight
  end

  -- render to canvas to allow 2x scaling
  love.graphics.setCanvas(playdate.graphics._canvas)
  love.graphics.setShader(playdate.graphics._shader)

  --[[ 
    Love2d won't allow a canvas to be set outside of the draw function, so we need to do this on the first frame of draw.
    Otherwise setting the bg color outside of playdate.update() won't be consistent with PD.
  --]]
  if firstFrame then
    local c = playdate.graphics._lastClearColor
    love.graphics.clear(c.r, c.g, c.b, 1)
    firstFrame = false
  end

  -- love requires that this is set every loop
  love.graphics.setFont(playdate.graphics.getFont().data)

  -- push main transform for draw offset
  love.graphics.push()
  love.graphics.translate(playdate.graphics._drawOffset.x, playdate.graphics._drawOffset.y)

  -- main update
  playdate.graphics.setImageDrawMode(playdate.graphics._drawMode)
  playdate.update()

  -- debug draw
  if playdate.debugDraw then
    playdate.graphics._shader:send("debugDraw", true)
    playdate.debugDraw()
    playdate.graphics._shader:send("debugDraw", false)
  end

  -- Not sure why, but we must reset to the default mode (copy = 0) otherwise
  -- modes "stick" through till the next frame and seems to apply to clear().
  -- Must also happen *here* - not tested, but maybe before pop() and canvas.draw()?
  playdate.graphics._shader:send("mode", 0)

  -- pop main transform for draw offset
  love.graphics.pop()

  -- pop canvas
  love.graphics.setCanvas()

  -- clear shader so that canvas is rendered normally
  love.graphics.setShader()

  -- always render pure white so its not tinted
  local r, g, b = love.graphics.getColor()
  love.graphics.setColor(1, 1, 1, 1)

  -- draw canvas to screen
  local currentCanvasScale = playbit.graphics.getCanvasScale()
  local x, y = playbit.graphics.getCanvasPosition()
  love.graphics.draw(playdate.graphics._canvas, x, y, 0, currentCanvasScale, currentCanvasScale)

  -- reset back to set color
  love.graphics.setColor(r, g, b, 1)

  -- update emulated input
  playdate.updateInput()
end

!end