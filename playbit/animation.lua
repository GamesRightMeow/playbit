local module = {}

module.loop = {}
module.loop.meta = {}
module.loop.meta.__index = module.loop.meta

function module.loop.new(delay, imagetable, shouldLoop, startFrame, endFrame)
  local loop = setmetatable({}, module.loop.meta)
!if LOVE2D then
  -- pd delay is in milliseconds (1 = 1000ms)
  delay = delay / 1000
  loop.imagetable = imagetable
  loop.frame = startFrame or 1
  loop.timer = delay
  loop.delay = delay
  loop.shouldLoop = shouldLoop
  loop.startFrame = startFrame or 1
  loop.endFrame = endFrame or imagetable:getLength()
!elseif PLAYDATE then
  loop.loop = playdate.graphics.animation.loop.new(delay, imagetable.imagetable, shouldLoop)
  loop.loop.startFrame = startFrame or 1
  loop.loop.endFrame = endFrame or imagetable:getLength()
!end
  return loop
end

function module.loop.meta:draw(x, y)
!if LOVE2D then
  self.imagetable:draw(self.frame, x, y)

  -- TODO: should this be updated independently of draw? what does the playdate do?
  self.timer = self.timer - pb.time.deltaTime()
  if self.timer <= 0 then
    self.timer = self.delay
    if self.frame + 1 > self.endFrame then
      if self.shouldLoop then
        self.frame = self.startFrame
      end
    else
      self.frame = self.frame + 1
    end
  end
!elseif PLAYDATE then
  self.loop:draw(x, y)
!end
end

-- TODO: blinker

return module