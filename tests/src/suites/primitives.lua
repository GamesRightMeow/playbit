local function drawCircle()
  playdate.graphics.clear(1)
  playdate.graphics.fillCircleAtPoint(200, 0, 10)
  playdate.graphics.drawCircleAtPoint(200, 50, 10)
  pbAssert.IsImageSimilar("primitives_drawCircle")
end

local function drawRect()
  playdate.graphics.clear(1)
  playdate.graphics.fillRect(200, 0, 10, 10)
  playdate.graphics.drawRect(200, 50, 10, 10)
  pbAssert.IsImageSimilar("primitives_drawRect")
end

return {
  { "drawCircle", drawCircle },
  { "drawRect", drawRect },
}