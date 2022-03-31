local App = {}

App.drawStats = false

--! if LOVE2D then
App.draw2x = true
--! end

-- TODO: add settings argument
function App.load()
  pb.graphics.setBackgroundColor(0)

  --! if LOVE2D then
  love.graphics.setDefaultFilter("nearest", "nearest")
  --! end

  pb.graphics.createFont(
    "playbit",
    "playbit/fonts/playbit.png",
    " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`_*#=[]'{}",
    1
  )

  if App.onLoad then
    App.onLoad()
  end
end

function App.update()
  pb.perf.beginFrameSample("__update")
  
  if App.onUpdate then
    App.onUpdate()
  end

  --! if LOVE2D then
  
  --! if DEBUG then
  -- TODO: expose stat toggle in playdates menu?
  if pb.input.getButtonDown("debug_stats") then
    App.drawStats = not App.drawStats
  end
  --! end
  
  if pb.input.getButtonDown("toggle_window_size") then
    App.draw2x = not App.draw2x
    if App.draw2x then
      love.window.setMode(800, 480)
    else
      love.window.setMode(400, 240)
    end
  end
  --! end

  pb.input.update();

  pb.perf.endFrameSample("__update")
end

function App.render()
  pb.perf.beginFrameSample("__render")

  --! if LOVE2D then
  if App.draw2x then
    love.graphics.scale(2, 2)
  end
  --! end

  -- default to included playbit font
  pb.graphics.setFont("playbit")

  if App.onRender then
    App.onRender()
  end

  pb.perf.endFrameSample("__render")

  --! if DEBUG then
  -- TODO: consider putting these in dedicated system if more entity-specific features are added
  if App.drawStats then
    pb.graphics.setColor(1)
    pb.graphics.rectangle(350, 0, 50, 41, true, 0)
    pb.graphics.setColor(0)

    pb.graphics.text("F", 351, 1, "left")
    pb.graphics.text(pb.perf.getFps(), 400, 1, "right")

    pb.graphics.text("U", 351, 9, "left")
    pb.graphics.text(pb.perf.getFrameSample("__update"), 400, 9, "right")

    pb.graphics.text("R", 351, 17, "left")
    pb.graphics.text(pb.perf.getFrameSample("__render"), 400, 17, "right")

    pb.graphics.text("E", 351, 25, "left")
    pb.graphics.text(App.scene.entityCount, 400, 25, "right")

    pb.graphics.text("M", 351, 33, "left")
    pb.graphics.text(math.ceil(pb.perf.getMemory()), 400, 33, "right")
  end
  --! end
end

return App