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

function playdate.update()
  local paths = playdate.file.listFiles("suites")
  local totalTests = 0
  local totalTestsPassed = 0
  for i=1, #paths do
    local path = paths[i]
    -- strip the extension
    path = string.sub(path, 1, #path - 4)
    local tests = playdate.file.load("suites/"..path)()
    for j=1, #tests do
      local test = tests[j]
      local testName = path.."_"..test[1]
      local result, message = pcall(test[2])
      if result then
        totalTestsPassed = totalTestsPassed + 1
        print("[PASS] "..testName)
      else
        print("[FAIL] "..testName.." > "..message)
      end
      totalTests = totalTests + 1
    end
  end
  
!if LOVE2D then
  print("--------------------------------------------------")
  print(totalTestsPassed.."/"..totalTests.." tests succeeded")
  print("--------------------------------------------------")
  print("Expected images saved to: "..love.filesystem.getWorkingDirectory().."/"..EXPECTED_IMAGE_PATH)
  print("Actual images saved to: "..love.filesystem.getSaveDirectory())
  love.event.quit()
!else
  playdate.simulator.exit()
!end
end

