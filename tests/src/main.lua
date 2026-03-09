@@"header.lua"
import("CoreLibs/graphics")
import("CoreLibs/string")
import("CoreLibs/object")

import("playbit/graphics")

import("pbassert")

EXPECTED_IMAGE_PATH = "tests/src/images/expected/" 

-- playdate saves images in B&W so we need playbit to render in B&W too
!if LOVE2D then
playbit.graphics.setColors({1,1,1,1}, {0,0,0,1})
!end

local logs = {}

function logMessage(msg)
  table.insert(logs, tostring(msg).."\n")
  print(msg)
end

local function writeLogs()
  local file = playdate.file.open("log.txt", playdate.file.kFileWrite)
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

function playdate.update()
  local suitePaths = playdate.file.listFiles("suites")
  local totalTests = 0
  local totalTestsPassed = 0
  for i=1, #suitePaths do
    local suitePath = suitePaths[i]
    -- strip the extension
    suitePath = string.sub(suitePath, 1, #suitePath - 4)
    local suite = playdate.file.load("suites/"..suitePath)()
    for testName, testMethod in pairs(suite) do
      local fullTestName = suitePath.."_"..testName
      playdate.graphics.clear()
      pbAssert.setImagePrefix(fullTestName)
      local result, message = runTest(testMethod)
      if result then
        totalTestsPassed = totalTestsPassed + 1
        logMessage("[ ] "..fullTestName)
      else
        logMessage("[!] "..fullTestName.." > "..message)
      end
      totalTests = totalTests + 1
    end
  end
  
  logMessage("----------------- TEST SUMMARY -------------------")
  logMessage(totalTests.." run")
  logMessage(totalTestsPassed.." passed")
  logMessage((totalTests - totalTestsPassed).." failed")
  logMessage("--------------------------------------------------")

!if LOVE2D then
  print("Expected images saved to: "..love.filesystem.getWorkingDirectory().."/"..EXPECTED_IMAGE_PATH)
  print("Actual images saved to: "..love.filesystem.getSaveDirectory())
  print("Playdate logs saved to: <PLAYDATE_SDK>/Disk/Data/com.gamesrightmeow.playbit-tests/log.txt")
  love.event.quit()
!else
  writeLogs()
  playdate.simulator.exit()
!end
end

