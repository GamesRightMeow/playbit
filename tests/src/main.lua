@@"header.lua"
import("CoreLibs/graphics")

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

function playdate.update()
  local expectedImagePath = "tests/src/images/expected/" 
  local paths = playdate.file.listFiles("suites")
  local totalTests = 0
  local totalTestsPassed = 0
  for i=1, #paths do
    local path = paths[i]
    -- strip the extension
    path = string.sub(path, 1, #path - 4)
    local tests = playdate.file.load("suites/"..path)()
    for j=1, #tests do
      totalTests = totalTests + 1
      local test = tests[j]
      local testName = path.."_"..test[1]
      test[2]()

      -- TODO: support unit tests

!if LOVE2D then
      love.graphics.setCanvas()
      local actualData = playbit.graphics.canvas:newImageData()
      local expectedData = love.image.newImageData("images/expected/"..testName..".png")
      local difference = getImageDifference(expectedData, actualData)
      -- allow some difference due due to Love2d different drawing algorithms
      local maxDiff = 0.01
      if difference > maxDiff then 
        print(testName.."=fail ("..tostring(difference)..")")
      else
        print(testName.."=pass ("..tostring(difference)..")")
        totalTestsPassed = totalTestsPassed + 1
      end
      love.filesystem.createDirectory("images/actual")
      actualData:encode("png", "images/actual/"..testName..".png")
      love.graphics.setCanvas(playbit.graphics.canvas)
!else
      local image = playdate.graphics.getWorkingImage()
      playdate.simulator.writeToFile(image, expectedImagePath..testName..".png")
!end
    end
  end
  
!if LOVE2D then
  print("--------------------------------------------------")
  print(totalTestsPassed.."/"..totalTests.." tests succeeded")
  print("--------------------------------------------------")
  print("Expected images saved to: "..love.filesystem.getWorkingDirectory().."/"..expectedImagePath)
  print("Actual images saved to: "..love.filesystem.getSaveDirectory())
  love.event.quit()
!else
  playdate.simulator.exit()
!end
end

