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

function tests.GetTextWidth_IsReturned()
  local font = playdate.graphics.font.new("fonts/Phozon/Phozon")
  local width = font:getTextWidth("hello world")
  pbAssert.AreEqual(width, 88)
end

function tests.GetHeight_IsReturned()
  local font = playdate.graphics.font.new("fonts/Phozon/Phozon")
  local width = font:getHeight()
  pbAssert.AreEqual(width, 8)
end

function tests.GetLeading_IsReturned()
  local font = playdate.graphics.font.new("fonts/Phozon/Phozon")
  local width = font:getLeading()
  pbAssert.AreEqual(width, 0)
end

function tests.SetLeading_IsSet()
  local font = playdate.graphics.font.new("fonts/Phozon/Phozon")
  local oldWidth = font:getLeading()
  font:setLeading(10)
  local width = font:getLeading()
  pbAssert.AreNotEqual(width, oldWidth)
  pbAssert.AreEqual(width, 10)
end

return tests