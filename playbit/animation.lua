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
  loop.paused = false
!elseif PLAYDATE then
  loop.data = playdate.graphics.animation.loop.new(delay, imagetable.imagetable, shouldLoop)
  loop.data.startFrame = startFrame or 1
  loop.data.endFrame = endFrame or imagetable:getLength()
!end
  return loop
end

function module.loop.meta:getFrame()
  !if LOVE2D then
    return self.frame
  !elseif PLAYDATE then
    return self.data.frame
  !end
end

function module.loop.meta:resetLoop()
!if LOVE2D then
  self.timer = self.delay
  self.paused = false
  self.frame = self.startFrame
!elseif PLAYDATE then
  self.data.paused = false
  self.data.valid = false
  self.data.frame = self.data.startFrame
!end
end

function module.loop.meta:isLoopComplete()
!if LOVE2D then
  return self.frame == self.endFrame and self.paused
!elseif PLAYDATE then
  return not self.data:isValid()
!end
end

function module.loop.meta:draw(x, y)
!if LOVE2D then
  self.imagetable:draw(self.frame, x, y)

  if not self.paused then
    self.timer = self.timer - pb.time.deltaTime()

    if self.timer <= 0 then
      if self.frame + 1 > self.endFrame then
        if self.shouldLoop then
          -- start over
          self.timer = self.delay
          self.frame = self.startFrame
        else
          -- no loop, done
          self.paused = true
        end
      else
        -- next frame
        self.timer = self.delay
        self.frame = self.frame + 1
      end
    end
  end
!elseif PLAYDATE then
  self.data:draw(x, y)
!end
end

-- TODO: blinker

return module