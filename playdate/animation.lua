playdate.graphics.animation = playdate.graphics.animation or {}

local module = {}
playdate.graphics.animation.loop = module

local meta = {}
meta.__index = meta
module.__index = meta

function module.new(delay, imageTable, shouldLoop)
  local animation = setmetatable({}, meta)
  
  animation.startFrame = 1
  animation.endFrame = 1
  animation.frame = 1
  animation.step = 1
  animation.pause = false
  animation._startTime = playdate.getCurrentTimeMilliseconds()

  animation.delay = delay or 100
  animation._imageTable = imageTable
  animation.shouldLoop = shouldLoop

  if imageTable then
    animation.endFrame = imageTable:getLength()
  end

  return animation
end

function meta:image(it)
  return self._imageTable
end

function meta:setImageTable(it)
  self._imageTable = it
end

function meta:isValid()
  if self.shouldLoop then
    return true
  end

  if self.frame > self.endFrame then
    return false
  end

  return true
end

function meta:draw(x, y, flip)
  if not self.pause then
    local elapsedTime = playdate.getCurrentTimeMilliseconds() - self._startTime
    self.frame = self.startFrame + math.floor(elapsedTime / self.delay) * self.step

    if self.frame > self.endFrame then
      if self.shouldLoop then
        self.frame = self.startFrame
        self._startTime = playdate.getCurrentTimeMilliseconds()
      else
        self.frame = self.endFrame
      end
    end
  end

  self._imageTable:drawImage(self.frame, x, y, flip)
end