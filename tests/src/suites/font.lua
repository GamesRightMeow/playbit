local tests = {}

function tests.DrawText_IsDrawn()
  playdate.graphics.drawText("HELLO WORLD", 0, 0)
  playdate.graphics.drawText("Foo", 100, 0)
  playdate.graphics.drawText("Bar", 0, 100)
  pbAssert.IsImageSimilar()
end

function tests.DrawTextAligned_IsDrawn()
  playdate.graphics.drawTextAligned("HELLO WORLD", 200, 0, 1)
  playdate.graphics.drawTextAligned("PLAYDATE", 200, 32, 2)
  playdate.graphics.drawTextAligned("FOOBAR", 200, 64, 3)
  pbAssert.IsImageSimilar()
end

return tests