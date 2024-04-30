@@"header.lua"

local font = playdate.graphics.font.new("fonts/Roobert/Roobert-11-Mono-Condensed")
playdate.graphics.setFont(font)

local render = true

function doImagesMatch(dataA, dataB)
  -- assume both images are playdate sized i.e. 400x240 pixels
  for x = 0, 399 do
    for y = 0, 239 do
      if dataA:getPixel(x, y) ~= dataB:getPixel(x, y) then
        return false
      end
    end
  end
  return true
end

function playdate.update()
  font:drawText("HELLO WORLD", 1, 0)
  love.graphics.setCanvas()
  local screenData = playdate.graphics._canvas:newImageData()
  local fileData = love.image.newImageData("tests/text.png")
  if not doImagesMatch(fileData, screenData) then
    print("images do not match")
  end
  
  -- love.graphics.captureScreenshot("test.png")
  love.event.quit()
end

