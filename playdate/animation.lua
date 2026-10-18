-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#C-graphics.animation.loop

playdate.graphics.animation = playdate.graphics.animation or {}

local module = {}
playdate.graphics.animation.loop = module

local meta = {}
module.__index = meta

meta.__index = function(table, key)
  if key == "paused" then
    return rawget(table, "_paused")
  end
  return meta[key]
end

-- like on playdate, unpausing carries on at the same frame as when the loop was paused
meta.__newindex = function(table, key, value)
  if key == "paused" then
    local now = playdate.getCurrentTimeMilliseconds()
    if value and not table._paused then
      rawset(table, "_pausedAt", now)
    elseif not value and table._paused then
      rawset(table, "_startTime", table._startTime + now - table._pausedAt)
    end
    rawset(table, "_paused", value)
  else
    rawset(table, key, value)
  end
end

local function updateFrame(self)
  if not self._paused then
    local elapsedTime = playdate.getCurrentTimeMilliseconds() - self._startTime
    self.frame = self.startFrame + math.floor(elapsedTime / self.delay) * self.step

    if self.frame > self.endFrame then
      if self.shouldLoop then
        self.frame = self.startFrame
        self._startTime = playdate.getCurrentTimeMilliseconds()
      else
        self.frame = self.endFrame
        self._valid = false
      end
    end
  end
end

function module.new(delay, imageTable, shouldLoop)
  local animation = setmetatable({}, meta)
  
  animation.startFrame = 1
  animation.endFrame = 1
  animation.frame = 1
  animation.step = 1
  animation._paused = false
  animation._startTime = playdate.getCurrentTimeMilliseconds()

  animation.delay = delay or 100
  animation._imageTable = imageTable
  animation.shouldLoop = shouldLoop
  animation._valid = true

  if imageTable then
    animation.endFrame = #imageTable
  end

  return animation
end

function meta:image()
  updateFrame(self)
  return self._imageTable[self.frame]
end

function meta:setImageTable(it)
  self._imageTable = it
end

function meta:isValid()
  return self._valid
end

function meta:draw(x, y, flip)
  local image = self:image()
  image:draw(x, y, flip)
end

-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#C-graphics.animation.blinker

local blinker = {}
playdate.graphics.animation.blinker = blinker
blinker.meta = {}
blinker.meta.__index = blinker.meta

function blinker.new(onDuration, offDuration, loop, cycles, default)
  error("[ERR] playdate.graphics.animation.blinker.new() is not yet implemented.")
end

function blinker.updateAll()
  error("[ERR] playdate.graphics.animation.blinker.updateAll() is not yet implemented.")
end

function blinker.meta:update()
  error("[ERR] playdate.graphics.animation.blinker:update() is not yet implemented.")
end

function blinker.meta:start(onDuration, offDuration, loop, cycles, default)
  error("[ERR] playdate.graphics.animation.blinker:start() is not yet implemented.")
end

function blinker.meta:startLoop()
  error("[ERR] playdate.graphics.animation.blinker:startLoop() is not yet implemented.")
end

function blinker.meta:stop()
  error("[ERR] playdate.graphics.animation.blinker:stop() is not yet implemented.")
end

function blinker.stopAll()
  error("[ERR] playdate.graphics.animation.blinker.stopAll() is not yet implemented.")
end

function blinker.meta:remove()
  error("[ERR] playdate.graphics.animation.blinker:remove() is not yet implemented.")
end