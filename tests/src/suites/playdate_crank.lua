local tests = {}

function tests.isCrankDocked()
  -- TODO: how do we meaningfully test isCrankDocked?
end

--[[ TODO: does it make sense to crankPosition when not docked?
The output depends on player input which I'm not sure makes 
sense being mock since its kind of 1:1 ]]--
function tests.getCrankPosition_IsZero_WhenDocked()
  local oldFunc = playdate.isCrankDocked
  playdate.isCrankDocked = function ()
    return true
  end

  local pos = playdate.getCrankPosition()
  pbAssert.AreEqual(pos, 0)

  playdate.isCrankDocked = oldFunc
end

function tests.getCrankChange()
  -- TODO: how do we meaningfully test getCrankChange?
end

function tests.getCrankTicks_OneTick()
  local oldFunc = playdate.getCrankPosition
  local crankPos = 0
  playdate.getCrankPosition = function ()
    return crankPos
  end

  playdate.getCrankTicks(1)
  crankPos = 1
  local ticks = playdate.getCrankTicks(360)
  pbAssert.AreEqual(ticks, 1)

  playdate.getCrankPosition = oldFunc
end

function tests.getCrankTicks_FourTick()
  local oldFunc = playdate.getCrankPosition
  local crankPos = 0
  playdate.getCrankPosition = function ()
    return crankPos
  end

  playdate.getCrankTicks(1)
  crankPos = 4
  local ticks = playdate.getCrankTicks(360)
  pbAssert.AreEqual(ticks, 4)

  playdate.getCrankPosition = oldFunc
end

function tests.getCrankTicks_TicksOverBorder()
  local oldFunc = playdate.getCrankPosition
  local crankPos = 359
  playdate.getCrankPosition = function ()
    return crankPos
  end

  playdate.getCrankTicks(1)
  crankPos = 0
  local ticks = playdate.getCrankTicks(360)
  pbAssert.AreEqual(ticks, 1)

  playdate.getCrankPosition = oldFunc
end

function tests.getCrankTicks_180_TickEveryDegree()
  local oldFunc = playdate.getCrankPosition
  local crankPos = 0
  playdate.getCrankPosition = function ()
    return crankPos
  end

  playdate.getCrankTicks(1)
  crankPos = 180
  local ticks = playdate.getCrankTicks(360)
  pbAssert.AreEqual(ticks, 180)

  playdate.getCrankPosition = oldFunc
end

--[[ Tests below make assertions that conceptually seem wrong.
Specifically it appears that rotations past 180 are treated as 
backwards rotations which doesn't seem right...but its how the
SDK currently functions as of SDK 3.0.3 ]]--

function tests.getCrankTicks_190_TickEveryDegree()
  local oldFunc = playdate.getCrankPosition
  local crankPos = 0
  playdate.getCrankPosition = function ()
    return crankPos
  end

  playdate.getCrankTicks(1)
  crankPos = 190
  local ticks = playdate.getCrankTicks(360)
  pbAssert.AreEqual(ticks, -170)

  playdate.getCrankPosition = oldFunc
end

function tests.getCrankTicks_360_OneTick()
  local oldFunc = playdate.getCrankPosition
  local crankPos = 0
  playdate.getCrankPosition = function ()
    return crankPos
  end

  playdate.getCrankTicks(1)
  crankPos = 360
  local ticks = playdate.getCrankTicks(1)
  pbAssert.AreEqual(ticks, 0)

  playdate.getCrankPosition = oldFunc
end

function tests.getCrankTicks_360_TickEveryDegree()
  local oldFunc = playdate.getCrankPosition
  local crankPos = 0
  playdate.getCrankPosition = function ()
    return crankPos
  end

  playdate.getCrankTicks(1)
  crankPos = 360
  local ticks = playdate.getCrankTicks(360)
  pbAssert.AreEqual(ticks, 0)

  playdate.getCrankPosition = oldFunc
end

return tests