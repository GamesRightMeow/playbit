@@"header.lua"
import("CoreLibs/graphics")
import("pbassert")

EXPECTED_IMAGE_PATH = "tests/src/images/expected/" 

local font = playdate.graphics.font.new("fonts/Phozon/Phozon")
playdate.graphics.setFont(font)

-- playdate saves images in B&W so we need playbit to render in B&W too
!if LOVE2D then
playbit.graphics.setColors({1,1,1,1}, {0,0,0,1})
!end

local logs = {}

function logMessage(msg)
  table.insert(logs, msg.."\n")
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
      local result, message = pcall(testMethod)
      if result then
        totalTestsPassed = totalTestsPassed + 1
        logMessage("[PASS] "..fullTestName)
      else
        logMessage("[FAIL] "..fullTestName.." > "..message)
      end
      totalTests = totalTests + 1
    end
  end
  
  logMessage("--------------------------------------------------")
  logMessage(totalTestsPassed.."/"..totalTests.." tests succeeded")
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

