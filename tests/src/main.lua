@@"header.lua"
import("CoreLibs/graphics")
import("CoreLibs/string")
import("CoreLibs/object")
import("CoreLibs/animation")
import("CoreLibs/crank")
import("CoreLibs/timer")
import("CoreLibs/easing")

import("playbit/graphics")

import("pbassert")

EXPECTED_IMAGE_PATH = "tests/src/images/expected/" 

!if LOVE2D then
-- playdate saves images in B&W so we need playbit to render in B&W too
playbit.graphics.setColors({1,1,1,1}, {0,0,0,1})
!else
-- we can't use the normal default font so set it to phozon
local defaultFont = playdate.graphics.font.new("fonts/Phozon/Phozon")
playdate.graphics.setFont(defaultFont)
!end

local logs = {}

function logMessage(msg)
  table.insert(logs, tostring(msg).."\n")
  print(msg)
end

local function writeLogs()
!if PLAYDATE then
  local fileName = "playdate_log.txt"
!else
  local fileName = "love_log.txt"
!end
  local file = playdate.file.open(fileName, playdate.file.kFileWrite)
  for i=1, #logs do
    file:write(logs[i])
  end
  file:flush()
  file:close()
end

local function getLines(message)
  local lines = {}
  for s in string.gmatch(message, "[^\n]*") do
    if #s > 1 then
      table.insert(lines, s)
    end
  end
  return lines
end

local function runTest(testMethod)
  local success, callstack = xpcall(testMethod, debug.traceback)
  if success then
    return success, nil
  else
    --[[ TODO: some callstacks don't parse right, so as a work around
    always log the entire callstack for easier debugging ]]--
    logMessage(callstack)
    local lines = getLines(callstack)
    -- assume 1st line always has the assertion message
    local firstSpace = string.find(lines[1], " ") + 1
    local assertMsgStr = string.sub(lines[1], firstSpace)
    -- assume 5th line is the line in the test
    local firstSpace = string.find(lines[5], " ")
    local testLineStr = string.sub(lines[5], 2, firstSpace)
    -- build final message
    local finalStr = testLineStr..assertMsgStr
    return success, finalStr
  end
end

local function cleanup()
  -- reset any state between tests
  playdate.graphics.clear()
  playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
  playdate.graphics.setColor(0)
  playdate.graphics.setBackgroundColor(1)
end

function playdate.update()
  local suitePaths = playdate.file.listFiles("suites")
  local totalTests = 0
  local totalTestsRun = 0
  local totalTestsPassed = 0
  local totalTestsSkipped = 0
  for i=1, #suitePaths do
    local suitePath = suitePaths[i]
    -- strip the extension
    suitePath = string.sub(suitePath, 1, #suitePath - 4)
    local suite, platform = playdate.file.load("suites/"..suitePath)()

    -- count tests
    for _ in pairs(suite) do totalTests = totalTests + 1 end

    -- skip suites that are platform specific
    -- TODO: support skipping specific tests
!if PLAYDATE then
    if platform and platform == "love2d" then
      for _ in pairs(suite) do totalTestsSkipped = totalTestsSkipped + 1 end
      goto continue
    end
!elseif LOVE2D then
    if platform and platform == "playdate" then
      for _ in pairs(suite) do totalTestsSkipped = totalTestsSkipped + 1 end
      goto continue
    end
!end

    for testName, testMethod in pairs(suite) do
      cleanup()
      local fullTestName = suitePath.."_"..testName
      pbAssert.setImagePrefix(fullTestName)
      local result, message = runTest(testMethod)
      if result then
        totalTestsPassed = totalTestsPassed + 1
        logMessage("[ ] "..fullTestName)
      else
        logMessage("[!] "..fullTestName.." > "..message)
      end
      totalTestsRun = totalTestsRun + 1
    end
    ::continue::
  end
  
  local now = playdate.getTime()
  local timeStr = now.year.."/"..now.month.."/"..now.day.." "..now.hour..":"..now.minute.."."..now.second

  logMessage("----------------- TEST SUMMARY -------------------")
  logMessage("Completed at "..timeStr)
  logMessage(totalTests.." found")
  logMessage(totalTestsRun.." run")
  logMessage(totalTestsSkipped.." skipped")
  logMessage(totalTestsPassed.." passed")
  logMessage((totalTestsRun - totalTestsPassed).." failed")
  logMessage("--------------------------------------------------")
  writeLogs()

!if LOVE2D then
  print("Expected images saved to: "..love.filesystem.getWorkingDirectory().."/"..EXPECTED_IMAGE_PATH)
  print("Actual images saved to: "..love.filesystem.getSaveDirectory())
  print("Playdate logs saved to: <PLAYDATE_SDK>/Disk/Data/com.gamesrightmeow.playbit-tests/playdate_log.txt")
  print("Love2d logs saved to: <LOVE2D_SAVE_DIRECTORY>/_tests_love2d/love_log.txt")
  love.event.quit()
!else
  playdate.simulator.exit()
!end
end

