!if LOVE2D then
require("playbit.graphics")

--[[ since there is no CoreLibs/playdate, this file should always
be included here so the methods are always available ]]--
require("playdate.playdate")
--[[ not really a way around including this one, but probably doesn't really
matter as all games are going to need to import graphics to draw stuff ]]--
require("playdate.graphics")

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

-- initialize playbit window using initial love.window mode
local windowWidth, windowHeight, windowFlags = love.window.getMode()
playbit.graphics.setWindowSize(windowWidth, windowHeight)
playbit.graphics.setFullscreen(windowFlags.fullscreen)

playbit.graphics.canvas:setFilter("nearest", "nearest")

love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineWidth(1)
love.graphics.setLineStyle("rough")

playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)
playdate.graphics.setColor(playdate.graphics.kColorBlack)

math.randomseed(os.time())

local font = playdate.graphics.font.new("fonts/Phozon/Phozon")
playdate.graphics.setFont(font)

local transparentColor = { 0, 0, 0, 0 }
local updateCoroutine

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
  local fullscreenType = playbit.graphics.getFullscreenType()
  local w, y, flags = love.window.getMode()
  if windowWidth ~= newWindowWidth or windowHeight ~= newWindowHeight or flags.fullscreen ~= fullscreen then
    flags.fullscreen = fullscreen
    flags.fullscreentype = fullscreenType
    -- stop window from ending up off screen when switching back from fullscreen
    if flags.x < 50 then
      flags.x = 50
    end
    if flags.y < 50 then
      flags.y = 50
    end

    love.window.updateMode(newWindowWidth, newWindowHeight, flags)
    windowWidth = newWindowWidth
    windowHeight = newWindowHeight
  end

  -- render to canvas to allow 2x scaling
  love.graphics.setCanvas(playbit.graphics.canvas)

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
  if not updateCoroutine or coroutine.status(updateCoroutine) == "dead" then
    updateCoroutine = coroutine.create(playdate.update)
  end

  local ok, err = coroutine.resume(updateCoroutine)
  if not ok then
    error(err)
  end

  -- pop main transform for draw offset
  love.graphics.pop()

  -- pop canvas
  love.graphics.setCanvas()

  -- store current shader
  local shader = love.graphics.getShader()

  -- setup shader for the final composition
  playbit.graphics.shaders.final:send("white", playbit.graphics.colorWhite)
  playbit.graphics.shaders.final:send("black", playbit.graphics.colorBlack)
  love.graphics.setShader(playbit.graphics.shaders.final)

  -- draw canvas to screen
  local canvasScale = playbit.graphics.getCanvasScale()
  local canvasWidth, canvasHeight = playbit.graphics.getCanvasSize()
  local framebufferScale = windowWidth / canvasWidth
  local x, y = playbit.graphics.getCanvasPosition()
  love.graphics.draw(playbit.graphics.canvas, x * framebufferScale, y * framebufferScale, 0, framebufferScale, framebufferScale)

!if DEBUG then
  -- debug draw
  if playdate.debugDraw then
    -- PD sets white color when in the debug mode.
    playdate.graphics.setColor(1)

    love.graphics.setCanvas(playbit.graphics.canvas)
    love.graphics.clear(0, 0, 0, 1)

    -- push main transform for draw offset
    love.graphics.push()
    love.graphics.translate(playbit.graphics.drawOffset.x, playbit.graphics.drawOffset.y)

    playdate.debugDraw()

    -- pop main transform for draw offset
    love.graphics.pop()

    -- pop canvas
    love.graphics.setCanvas()

    -- white pixels are drawn in the debugDrawColor, black pixels are transparent
    playbit.graphics.shaders.final:send("white", playbit.graphics.debugDrawColor)
    playbit.graphics.shaders.final:send("black", transparentColor)
    love.graphics.setShader(playbit.graphics.shaders.final)

    -- draw canvas to screen
    love.graphics.draw(playbit.graphics.canvas, x * framebufferScale, y * framebufferScale, 0, framebufferScale, framebufferScale)
  end
!end

  -- reset back the shader
  love.graphics.setShader(shader)

  -- update emulated input
  playdate.updateInput()
end

!end