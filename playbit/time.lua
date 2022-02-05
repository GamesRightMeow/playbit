local Time = {}

function Time.deltaTime()
  --! if LOVE2D then
  return love.timer.getDelta()
  --! else
  return 0
  --! end
end

return Time