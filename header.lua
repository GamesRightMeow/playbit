!if LOVE2D then
require("playbit.graphics")

--[[ since there is no CoreLibs/playdate, this file should always 
be included here so the methods are always available ]]--
require("playdate.playdate")
playdate = playdate or {}

function import(path)
  if string.match(path, "^CoreLibs/") then
    path = string.gsub(path, "/", ".")
    path = string.gsub(path, "CoreLibs", "playdate")
    return require(path)
  end
  path = string.gsub(path, "/", ".")
  return require(path)
end

local firstFrame = true
local windowWidth, windowHeight = playbit.graphics.getWindowSize()

playbit.graphics.canvas:setFilter("nearest", "nearest")

love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineWidth(1)
love.graphics.setLineStyle("rough")

playbit.graphics.backgroundColor = playbit.graphics.colorWhite

local c = playbit.graphics.colorBlack
playbit.graphics.drawColor = c
love.graphics.setColor(c[1], c[2], c[3], c[4])

math.randomseed(os.time())

function love.draw()
  -- must be changed at start of frame when canvas is not active
  local newCanvasWidth, newCanvasHeight = playbit.graphics.getCanvasSize()
  local canvasWidth = playbit.graphics.canvas:getWidth()
  local canvasHeight = playbit.graphics.canvas:getHeight()
  if canvasWidth ~= newCanvasWidth or canvasHeight ~= newCanvasHeight then
    playbit.graphics.canvas = love.graphics.newCanvas(newCanvasWidth, newCanvasHeight)
  end

  -- must be changed at start of frame - love2d doesn't allow changing window size with canvas active
  local newWindowWidth, newWindowHeight = playbit.graphics.getWindowSize()
  local fullscreen = playbit.graphics.getFullscreen()
  local w, y, flags = love.window.getMode()
  if windowWidth ~= newWindowWidth or windowHeight ~= newWindowHeight or flags.fullscreen ~= fullscreen then
    flags.fullscreen = fullscreen

    -- stop window from ending up off screen when switching back from fullscreen
    if flags.x < 50 then
      flags.x = 50
    end
    if flags.y < 50 then
      flags.y = 50
    end

    love.window.setMode(newWindowWidth, newWindowHeight, flags)
    windowWidth = newWindowWidth
    windowHeight = newWindowHeight
  end

  -- render to canvas to allow 2x scaling
  love.graphics.setCanvas(playbit.graphics.canvas)
  love.graphics.setShader(playbit.graphics.shader)

  --[[ 
    Love2d won't allow a canvas to be set outside of the draw function, so we need to do this on the first frame of draw.
    Otherwise setting the bg color outside of playdate.update() won't be consistent with PD.
  --]]
  if firstFrame then
    local c = playbit.graphics.lastClearColor
    love.graphics.clear(c.r, c.g, c.b, 1)
    firstFrame = false
  end

  -- love requires that this is set every loop
  love.graphics.setFont(playbit.graphics.activeFont.data)

  -- push main transform for draw offset
  love.graphics.push()
  love.graphics.translate(playbit.graphics.drawOffset.x, playbit.graphics.drawOffset.y)

  -- main update
  playdate.update()

  -- debug draw
  if playdate.debugDraw then
    playbit.graphics.shader:send("debugDraw", true)
    playdate.debugDraw()
    playbit.graphics.shader:send("debugDraw", false)
  end

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
  love.graphics.draw(playbit.graphics.canvas, x, y, 0, currentCanvasScale, currentCanvasScale)

  -- reset back to set color
  love.graphics.setColor(r, g, b, 1)

  -- update emulated input
  playdate.updateInput()
end

!end