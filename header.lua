!(
function IMPORT(path)
  -- path comes in with quotes, remove them
  path = path:sub(2, #path - 1)

  if PLAYDATE then
    return outputLuaTemplate("import(?)", path)
  elseif LOVE2D then
    if string.match(path, "^CoreLibs/") then
      -- ignore these imports, since the playdate namespace is already reimplemented in the global namespace
      return
    end

    path = string.gsub(path, "/", ".")
    return outputLuaTemplate("require(?)", path)
  end
end
)

!if LOVE2D then
require("playdate.playdate")
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

-- load pdxinfo into memory
playdate.metadata = {}
if love.filesystem.getInfo("pdxinfo") then
  local pdxinfo = love.filesystem.newFile("pdxinfo")
  pdxinfo:open("r")
  for line in pdxinfo:lines() do
    local index = line:find("=")
    local key = line:sub(1, index - 1)
    local value = line:sub(index + 1)
    playdate.metadata[key] = value
  end
end

local firstFrame = true

playdate.graphics._canvas:setFilter("nearest", "nearest")

love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineWidth(1)
love.graphics.setLineStyle("rough")

playdate.graphics.setBackgroundColor(1)
playdate.graphics.setColor(0)

math.randomseed(os.time())

playbit = {}

--- Sets the scale of the screen in Love2D
---@param scale number
playbit.screenScale = 1
playbit.newScreenScale = 1
function playbit.setScreenScale(scale)
  playbit.newScreenScale = scale
end

function love.draw()
  -- must be changed first, love2d doesn't like changing res with canvas active
  if playbit.newScreenScale ~= playbit.screenScale then
    playbit.screenScale = playbit.newScreenScale
    love.window.setMode(400 * playbit.screenScale, 240 * playbit.screenScale)
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
  love.graphics.draw(playdate.graphics._canvas, 0, 0, 0, playbit.screenScale, playbit.screenScale)

  -- reset back to set color
  love.graphics.setColor(r, g, b, 1)

  -- update emulated input
  playdate.updateInput()
end

!end