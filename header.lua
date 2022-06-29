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

local lastDrawMode = "copy"
local pb_draw2x = false
local firstFrame = true

playdate.graphics._canvas:setFilter("nearest", "nearest")

love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineWidth(1)
love.graphics.setLineStyle("rough")
love.graphics.setShader(playdate.graphics._shader)

playdate.graphics.setBackgroundColor(1)
playdate.graphics.setColor(0)

math.randomseed(os.time())

function love.draw()  
  if love.keyboard.isDown("f1") then
    pb_draw2x = not pb_draw2x
    if pb_draw2x then
      love.window.setMode(800, 480)
    else
      love.window.setMode(400, 240)
    end
  end

  -- render to canvas to allow 2x scaling
  love.graphics.setCanvas(playdate.graphics._canvas)

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

  playdate.graphics.setImageDrawMode(lastDrawMode)
  playdate.update()

  -- Not sure why, but we must reset to the default mode (copy = 0) otherwise
  -- modes "stick" through till the next frame and seems to apply to clear().
  -- Must also happen *here* - not tested, but maybe before pop() and canvas.draw()?
  lastDrawMode = playdate.graphics._drawMode
  playdate.graphics.setImageDrawMode("copy")

  -- pop main transform for draw offset
  love.graphics.pop()

  -- pop canvas
  love.graphics.setCanvas()

  -- always render pure white so its not tinted
  local r, g, b = love.graphics.getColor()
  love.graphics.setColor(1, 1, 1, 1)

  -- draw canvas to screen
  if pb_draw2x then
    love.graphics.draw(playdate.graphics._canvas, 0, 0, 0, 2, 2)
  else
    love.graphics.draw(playdate.graphics._canvas, 0, 0, 0, 1, 1)
  end

  -- reset back to set color
  love.graphics.setColor(r, g, b, 1)

  -- update emulated input
  playdate.updateInput()
end

!end