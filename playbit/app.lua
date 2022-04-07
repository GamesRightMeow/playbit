local module = {}

module.drawStats = false

--! if LOVE2D then
module.draw2x = false
--! end

-- TODO: add settings argument
function module.load()
  -- default to white on black
  pb.graphics.setBackgroundColor(0)
  pb.graphics.setColor(1)

  --! if LOVE2D then
  love.graphics.setDefaultFilter("nearest", "nearest")
  --! end

  pb.graphics.createFont(
    "default",
    "playbit/fonts/Roobert-9-Mono-Condensed",
    " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~",
    1
  )

  pb.graphics.setFont("default")

  if module.onLoad then
    module.onLoad()
  end
end

function module.update()
  pb.perf.beginFrameSample("__update")
  
  if module.onUpdate then
    module.onUpdate()
  end

  --! if LOVE2D then
  
  --! if DEBUG then
  -- TODO: expose stat toggle in playdates menu?
  if pb.input.getButtonDown("debug_stats") then
    module.drawStats = not module.drawStats
  end
  --! end
  
  if pb.input.getButtonDown("toggle_window_size") then
    module.draw2x = not module.draw2x
    if module.draw2x then
      love.window.setMode(800, 480)
    else
      love.window.setMode(400, 240)
    end
  end
  --! end

  pb.input.update();

  pb.perf.endFrameSample("__update")
end

function module.render()
  pb.perf.beginFrameSample("__render")

  --! if LOVE2D then
  if module.draw2x then
    love.graphics.scale(2, 2)
  end

  -- love requires that this is set every loop
  love.graphics.setFont(pb.graphics.getActiveFont())

  love.graphics.setShader(pb.graphics.playbitShader)
  --! end

  --! if PLAYDATE then
  playdate.graphics.clear()
  --! end

  if module.onRender then
    module.onRender()
  end

  pb.perf.endFrameSample("__render")

  --! if DEBUG then
  -- TODO: consider putting these in dedicated system if more entity-specific features are added
  if module.drawStats then
    pb.graphics.setColor(1)
    pb.graphics.rectangle(350, 0, 50, 41, true, 0)

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
  --! end

  --! if PLAYDATE then
  pb.time.lastFrameTime = pb.time.getTime()
  --! end
end

return module