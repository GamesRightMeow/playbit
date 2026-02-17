@@"header.lua"
import("CoreLibs/graphics")

local EXPECTED_IMAGE_PATH = "tests/src/images/expected/" 

local font = playdate.graphics.font.new("fonts/Phozon/Phozon")
playdate.graphics.setFont(font)

-- playdate saves images in B&W so we need playbit to render in B&W too
!if LOVE2D then
playbit.graphics.setColors({1,1,1,1}, {0,0,0,1})
!end

function getImageDifference(dataA, dataB)
  -- assume both images are playdate sized i.e. 400x240 pixels
  local difference = 0
  local total = 400 * 240
  for x = 0, 399 do
    for y = 0, 239 do
      if dataA:getPixel(x, y) ~= dataB:getPixel(x, y) then
        difference = difference + 1
      end
    end
  end
  return difference / total
end

function pbAssert_ImageIsSame(path, maxDifference)
!if LOVE2D then
  if not maxDifference then
    -- default to allowing some difference due to Love2d different drawing algorithms
    maxDifference = 0.01  
  end

  love.graphics.setCanvas()
  local actualData = playbit.graphics.canvas:newImageData()
  local expectedData = love.image.newImageData("images/expected/"..path..".png")
  local difference = getImageDifference(expectedData, actualData)
  
  local success = false
  if difference <= maxDifference then 
    success = true
  end

  love.filesystem.createDirectory("images/actual")
  actualData:encode("png", "images/actual/"..path..".png")
  love.graphics.setCanvas(playbit.graphics.canvas)
  return success
!else
  local image = playdate.graphics.getWorkingImage()
  playdate.simulator.writeToFile(image, EXPECTED_IMAGE_PATH..path..".png")
  -- always return true on Playdate since we're not actually doing the tests here
  return true
!end
end

function pbAssert_IsTrue(expected, actual)
  return valueA == valueB
end

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
      local success = test[2]()
      if success then
        totalTestsPassed = totalTestsPassed + 1
        print("[PASS] "..testName)
      else
        print("[FAIL] "..testName)
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

