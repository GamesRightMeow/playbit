local module = {}

module.drawStats = false

!if LOVE2D then
module.draw2x = false
module.canvas = {}
!end

-- TODO: add settings argument
function module.load()
  -- default to white on black
  pb.graphics.setBackgroundColor(0)
  pb.graphics.setColor(1)

!if LOVE2D then
  module.canvas = love.graphics.newCanvas()
  module.canvas:setFilter("nearest", "nearest")

  love.graphics.setDefaultFilter("nearest", "nearest")
  love.graphics.setLineWidth(1)
  love.graphics.setLineStyle("rough")

  math.randomseed(os.time())
!else
  math.randomseed(playdate.getSecondsSinceEpoch())
  -- love2d doesn't have a stoke location option, so set outside by default to match
  playdate.graphics.setStrokeLocation(playdate.graphics.kStrokeOutside)
!end

  -- TODO: reenabled when I add a custom font for platbit, since I cant re-distribute PD fonts
  -- pb.graphics.createFont(
  --   "default",
  --   "playbit/fonts/Roobert-9-Mono-Condensed",
  --   " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~",
  --   1
  -- )

  -- pb.graphics.setFont("default")

  if module.onLoad then
    module.onLoad()
  end
end

function module.update()
!if LOVE2D then
  
!if DEBUG then
  -- TODO: expose stat toggle in playdates menu?
  if pb.input.getButtonDown("debug_stats") then
    module.drawStats = not module.drawStats
  end
!end
  
  if pb.input.getButtonDown("toggle_window_size") then
    module.draw2x = not module.draw2x
    if module.draw2x then
      love.window.setMode(800, 480)
    else
      love.window.setMode(400, 240)
    end
  end
!end

!if LOVE2D then
  -- render to canvas to allow 2x scaling
  love.graphics.setCanvas(module.canvas)
  love.graphics.clear()

  -- love requires that this is set every loop
  love.graphics.setFont(pb.graphics.getActiveFont())
  love.graphics.setShader(pb.graphics.playbitShader)
  
  -- set every update to match behavior on playdate
  pb.graphics.setColor(1)

  -- push main transform for draw offset
  love.graphics.push()
  if module.draw2x then
    love.graphics.scale(2, 2)
  end
!elseif PLAYDATE then
  playdate.graphics.clear()
!end

  module.onUpdate()

!if LOVE2D then
  -- pop main transform for draw offset
  love.graphics.pop()

  -- draw canvas
  love.graphics.setCanvas()
  if module.draw2x then
    love.graphics.draw(module.canvas, 0, 0, 0, 2, 2)
  else
    love.graphics.draw(module.canvas, 0, 0, 0, 1, 1)
  end
!elseif PLAYDATE then
  playdate.graphics.setDrawOffset(0,0)
!end

!if DEBUG then
  if module.drawStats then
    -- TODO: render with playbit font...when added
    pb.graphics.setColor(1)
    pb.graphics.fillRect(350, 0, 50, 50)

    pb.graphics.setImageDrawMode("fillBlack")

    pb.graphics.text("F", 351, 1, "left")
    pb.graphics.text(pb.perf.getFps(), 400, 1, "right")

    pb.graphics.text("U", 351, 9, "left")
    pb.graphics.text(pb.perf.getFrameSample("__update"), 400, 9, "right")

    pb.graphics.text("R", 351, 17, "left")
    pb.graphics.text(pb.perf.getFrameSample("__render"), 400, 17, "right")

    pb.graphics.text("M", 351, 33, "left")
    pb.graphics.text(math.ceil(pb.perf.getMemory()), 400, 33, "right")
  end
!end

  pb.time.updateDeltaTime()

  pb.input.update()
end

return module