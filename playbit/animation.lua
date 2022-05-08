local module = {}

module.loop = {}
module.loop.meta = {}
module.loop.meta.__index = module.loop.meta

function module.loop.new(delay, imagetable, shouldLoop)
  local loop = setmetatable({}, module.loop.meta)
!if LOVE2D then
  -- pd delay is in milliseconds (1 = 1000ms) and runs at 30fps (so 2x longer delay)
  delay = delay / 1000 * 2
  loop.imagetable = imagetable
  loop.frame = 1
  loop.timer = delay
  loop.delay = delay
  loop.shouldLoop = shouldLoop
!elseif PLAYDATE then
  loop.loop = playdate.graphics.animation.loop.new(delay, imagetable.imagetable, shouldLoop)
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
    if self.frame + 1 > self.imagetable:getLength() then
      if self.shouldLoop then
        self.frame = 1
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