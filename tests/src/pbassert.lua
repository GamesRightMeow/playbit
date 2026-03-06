pbAssert = {}

local imageAssertPrefix = nil
local usedImagePaths = {}

local function getImageDifference(dataA, dataB)
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

function pbAssert.setImagePrefix(value)
  imageAssertPrefix = value
end

--- On Playdate this saves an image to file. On Love2d this compares the previously
--- saved image from playdate to the Love2ds current buffer and does a pixel-by-pixel
--- comparison to of the two. The resulting different is a float that represents the
--- number of pixels that are different. 
function pbAssert.IsImageSimilar(path, maxDifference)
  if path and #path > 0 then
    path = imageAssertPrefix.."_"..path
  else
    path = imageAssertPrefix
  end

!if LOVE2D then
  if not maxDifference then
    -- default to allowing some difference due to Love2d different drawing algorithms
    maxDifference = 0.01  
  end

  if usedImagePaths[path] then
    error("Image path '"..path.."' has already been used")
  end
  usedImagePaths[path] = true

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

function pbAssert.IsTrue(actual)
  if actual == false then
    error("Actual was expected to be true")
  end
end

function pbAssert.IsFalse(actual)
  if actual == true then
    error("Actual was expected to be false")
  end
end

function pbAssert.AreEqual(actual, expected)
  if actual ~= expected then
    error("Expected: "..tostring(expected).." Actual: "..tostring(actual))
  end
end

function pbAssert.AreNotEqual(actual, expected)
  if actual == expected then
    error("Expected: "..tostring(expected).." Actual: "..tostring(actual))
  end
end

function pbAssert.IsNil(actual)
  if actual ~= nil then
    error("Actual was expected to be nil")
  end
end

function pbAssert.IsNotNil(actual)
  if actual == nil then
    error("Actual was expected to be not nil")
  end
end