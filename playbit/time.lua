local module = {}

module.lastFrameTime = 0

function module.getTime()
  --! if LOVE2D then
  return love.timer.getTime()
  --! else
  return playdate.getCurrentTimeMilliseconds()
  --! end
end

function module.deltaTime()
  --! if LOVE2D then
  return love.timer.getDelta()
  --! else
  return (module.getTime() - module.lastFrameTime) / 60 / 30
  --! end
end

return module