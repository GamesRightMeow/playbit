local tests = {}

function tests.GetTimeReturnsTable()
  local time = playdate.getTime()
  pbAssert.IsNotNil(time)
end

function tests.GetTimeHasYear()
  local time = playdate.getTime()
  pbAssert.IsNotNil(time.year)
  pbAssert.IsTrue(time.year >= 2000)
end

function tests.GetTimeHasMonth()
  local time = playdate.getTime()
  pbAssert.IsNotNil(time.month)
  pbAssert.IsTrue(time.month >= 1 and time.month <= 12)
end

function tests.GetTimeHasDay()
  local time = playdate.getTime()
  pbAssert.IsNotNil(time.day)
  pbAssert.IsTrue(time.day >= 1 and time.day <= 31)
end

function tests.GetTimeHasHour()
  local time = playdate.getTime()
  pbAssert.IsNotNil(time.hour)
  pbAssert.IsTrue(time.hour >= 0 and time.hour <= 23)
end

function tests.GetTimeHasMinute()
  local time = playdate.getTime()
  pbAssert.IsNotNil(time.minute)
  pbAssert.IsTrue(time.minute >= 0 and time.minute <= 59)
end

function tests.GetTimeHasSecond()
  local time = playdate.getTime()
  pbAssert.IsNotNil(time.second)
  pbAssert.IsTrue(time.second >= 0 and time.second <= 59)
end

function tests.GetCurrentTimeMillisecondsReturnsNumber()
  local ms = playdate.getCurrentTimeMilliseconds()
  pbAssert.IsNotNil(ms)
end

function tests.GetCurrentTimeMillisecondsIsPositive()
  local ms = playdate.getCurrentTimeMilliseconds()
  pbAssert.IsTrue(ms >= 0)
end

function tests.GetCurrentTimeMillisecondsIncreases()
  local ms1 = playdate.getCurrentTimeMilliseconds()
  local ms2 = playdate.getCurrentTimeMilliseconds()
  pbAssert.IsTrue(ms2 >= ms1)
end

function tests.GetSecondsSinceEpochReturnsNumber()
  local seconds = playdate.getSecondsSinceEpoch()
  pbAssert.IsNotNil(seconds)
end

function tests.GetSecondsSinceEpochIsPositive()
  local seconds = playdate.getSecondsSinceEpoch()
  pbAssert.IsTrue(seconds > 0)
end

return tests
