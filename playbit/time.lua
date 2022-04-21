local module = {}

module.lastFrameTime = 0

function module.getTime()
  --! if LOVE2D then
  -- love2d returns time in seconds
  return love.timer.getTime()
  --! else
  -- love2d returns time in milliseconds
  return playdate.getCurrentTimeMilliseconds() / 1000
  --! end
end

function module.deltaTime()
  --! if LOVE2D then
  return (module.getTime() - module.lastFrameTime)
  --! else
  return (module.getTime() - module.lastFrameTime) 
  --! end
end

return module