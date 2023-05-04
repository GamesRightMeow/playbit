local module = {}
playbit = playbit or {}
playbit.time = module

local lastFrameTime = 0
local deltaTime = 0
local totalAvgDeltaTime = 0
local avgDeltaTime = 0
local avgDeltaTimeCount = 0

function module.getTime()
!if LOVE2D then
  -- love2d returns time in seconds
  return love.timer.getTime()
!else
  -- playdate returns time in milliseconds
  return playdate.getCurrentTimeMilliseconds() / 1000
!end
end

function module.updateDeltaTime()
  local timeNow = module.getTime()

  -- calc delta time
  deltaTime = timeNow - lastFrameTime

  -- reset average delta time
  if avgDeltaTimeCount == 100 then
    totalAvgDeltaTime = 0
    avgDeltaTimeCount = 0
  end

  -- calc average delta time
  totalAvgDeltaTime = totalAvgDeltaTime + deltaTime
  avgDeltaTimeCount = avgDeltaTimeCount + 1
  avgDeltaTime = totalAvgDeltaTime / avgDeltaTimeCount

  -- set last frame to current
  lastFrameTime = timeNow
  
  return deltaTime
end

function module.avgDeltaTime()
  return avgDeltaTime
end

function module.deltaTime()
  return deltaTime
end