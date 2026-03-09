local tests = {}

function tests.FillCircleAtPoint_IsDrawn()
  playdate.graphics.fillCircleAtPoint(200, 50, 10)
  pbAssert.IsImageSimilar()
end

function tests.DrawCircleAtPoint_IsDrawn()
  playdate.graphics.drawCircleAtPoint(200, 10, 10)
  pbAssert.IsImageSimilar()
end

function tests.FillRect_IsDrawn()
  playdate.graphics.fillRect(200, 0, 10, 10)
  pbAssert.IsImageSimilar()
end

function tests.DrawRect_IsDrawn()
  playdate.graphics.drawRect(200, 50, 10, 10)
  pbAssert.IsImageSimilar()
end

function tests.Clear_DoesClear()
  playdate.graphics.fillRect(0, 0, 400, 240)
  playdate.graphics.clear()
  pbAssert.IsImageSimilar("clear")
  playdate.graphics.clear(playdate.graphics.kColorWhite)
  pbAssert.IsImageSimilar("white")
  playdate.graphics.clear(playdate.graphics.kColorBlack)
  pbAssert.IsImageSimilar("black")
end

function tests.DrawLine_IsDrawn()
  playdate.graphics.drawLine(0, 0, 400, 240)
  playdate.graphics.setLineWidth(1)
  playdate.graphics.drawLine(0, 50, 400, 50)
  playdate.graphics.setLineWidth(10)
  playdate.graphics.drawLine(0, 100, 400, 100)
  playdate.graphics.setLineWidth(1)
  pbAssert.IsImageSimilar()
end

function tests.DrawArc_IsDrawn()
  playdate.graphics.drawArc(50, 50, 20, 0, 360)
  playdate.graphics.drawArc(50, 100, 20, 0, 90)
  playdate.graphics.drawArc(50, 150, 20, 0, 180)
  pbAssert.IsImageSimilar()
end

function tests.DrawPixel_IsDrawn()
  playdate.graphics.clear()
  playdate.graphics.drawPixel(200, 120)
  pbAssert.IsImageSimilar()
end

function tests.DrawText_IsDrawn()
  playdate.graphics.drawText("hello world", 0, 0)
  -- TODO: test other params when implemented
  pbAssert.IsImageSimilar()
end

function tests.DrawTextAligned_IsDrawn()
  playdate.graphics.drawTextAligned("hello world", 0, 0, 0)
  playdate.graphics.drawTextAligned("foobar", 0, 20, 1)
  playdate.graphics.drawTextAligned("playdate", 0, 40, 2)
  -- TODO: test other params when implemented
  pbAssert.IsImageSimilar()
end

function tests.Context_IsNotDrawn()
  local img = playdate.graphics.image.new(400, 200)
  playdate.graphics.pushContext(img)
  playdate.graphics.fillRect(200, 120, 20, 20)
  playdate.graphics.popContext()
  pbAssert.IsImageSimilar()
end

function tests.Context_IsDrawn()
  local img = playdate.graphics.image.new(400, 200)
  playdate.graphics.pushContext(img)
  playdate.graphics.fillRect(200, 120, 20, 20)
  playdate.graphics.popContext()
  img:draw(0, 0)
  pbAssert.IsImageSimilar()
end

function tests.FontSize_IsReturned()
  local font = playdate.graphics.font.new("fonts/Phozon/Phozon")
  playdate.graphics.setFont(font)
  local size = playdate.graphics.getTextSize("hello world")
  pbAssert.AreEqual(size, 88)
end

function tests.SetFont_NilDoesNotClear()
  local oldFont = playdate.graphics.getFont()
  local font = playdate.graphics.font.new("fonts/Phozon/Phozon")
  playdate.graphics.setFont(font)
  pbAssert.AreEqual(playdate.graphics.getFont(), font)
  pbAssert.AreNotEqual(playdate.graphics.getFont(), oldFont)
  playdate.graphics.setFont(nil)
  pbAssert.AreEqual(playdate.graphics.getFont(), font)
end

function tests.Font_IsSet()
  local oldFont = playdate.graphics.getFont()
  local font = playdate.graphics.font.new("fonts/Phozon/Phozon")
  playdate.graphics.setFont(font)
  pbAssert.AreEqual(playdate.graphics.getFont(), font)
  pbAssert.AreNotEqual(playdate.graphics.getFont(), oldFont)
end

function tests.DrawOffset_IsUsed(x, y)
  playdate.graphics.setDrawOffset(50, 50)
  playdate.graphics.fillRect(0, 0, 50, 50)
  pbAssert.IsImageSimilar("offset")
  playdate.graphics.setDrawOffset(0, 0)
  pbAssert.IsImageSimilar("zeroed")
end

function tests.DrawOffset_IsReturned(x, y)
  playdate.graphics.setDrawOffset(50, 50)
  local x, y = playdate.graphics.getDrawOffset()
  pbAssert.AreEqual(x, 50)
  pbAssert.AreEqual(y, 50)
  playdate.graphics.setDrawOffset(0, 0)
end

function tests.SetBackgroundColor_IsUsed()
  playdate.graphics.setBackgroundColor(playdate.graphics.kColorBlack)
  playdate.graphics.clear()
  pbAssert.IsImageSimilar("black")
  playdate.graphics.setBackgroundColor(playdate.graphics.kColorWhite)
  playdate.graphics.clear()
  pbAssert.IsImageSimilar("white")
end

function tests.SetColor_IsUsed(x, y)
  playdate.graphics.clear(playdate.graphics.kColorWhite)
  playdate.graphics.setColor(playdate.graphics.kColorBlack)
  playdate.graphics.drawArc(10, 10, 4, 0, 180)
  playdate.graphics.fillRect(10, 20, 8, 8)
  playdate.graphics.drawRect(10, 30, 8, 8)
  playdate.graphics.drawCircleAtPoint(10, 40, 4)
  playdate.graphics.fillCircleAtPoint(10, 50, 4)
  playdate.graphics.drawLine(10, 60, 100, 60)
  playdate.graphics.drawPixel(10, 70)
  pbAssert.IsImageSimilar("black")

  playdate.graphics.clear(playdate.graphics.kColorBlack)
  playdate.graphics.setColor(playdate.graphics.kColorWhite)
  playdate.graphics.drawArc(10, 10, 4, 0, 180)
  playdate.graphics.fillRect(10, 20, 8, 8)
  playdate.graphics.drawRect(10, 30, 8, 8)
  playdate.graphics.drawCircleAtPoint(10, 40, 4)
  playdate.graphics.fillCircleAtPoint(10, 50, 4)
  playdate.graphics.drawLine(10, 60, 100, 60)
  playdate.graphics.drawPixel(10, 70)
  pbAssert.IsImageSimilar("white")
end

function tests.Constants_AreCorrect()
  --[[ these will never fail on Love, but want to make sure
  these are true on Playdate incase the SDK changes the values
  in a future release ]]--
  pbAssert.AreEqual(playdate.graphics.kColorWhite, 1)
  pbAssert.AreEqual(playdate.graphics.kColorBlack, 0)

  pbAssert.AreEqual(playdate.graphics.kImageUnflipped, 0)
  pbAssert.AreEqual(playdate.graphics.kImageFlippedX, 1)
  pbAssert.AreEqual(playdate.graphics.kImageFlippedY, 2)
  pbAssert.AreEqual(playdate.graphics.kImageFlippedXY, 3)

  pbAssert.AreEqual(playdate.graphics.kDrawModeCopy, 0)
  pbAssert.AreEqual(playdate.graphics.kDrawModeWhiteTransparent, 1)
  pbAssert.AreEqual(playdate.graphics.kDrawModeBlackTransparent, 2)
  pbAssert.AreEqual(playdate.graphics.kDrawModeFillWhite, 3)
  pbAssert.AreEqual(playdate.graphics.kDrawModeFillBlack, 4)
  pbAssert.AreEqual(playdate.graphics.kDrawModeXOR, 5)
  pbAssert.AreEqual(playdate.graphics.kDrawModeNXOR, 6)
  pbAssert.AreEqual(playdate.graphics.kDrawModeInverted, 7)
end

function tests.DrawMode_Copy()
  playdate.graphics.setColor(playdate.graphics.kColorWhite)
  playdate.graphics.fillRect(0, 0, 200, 240)
  playdate.graphics.setColor(playdate.graphics.kColorBlack)
  playdate.graphics.fillRect(200, 0, 200, 240)
  local img = playdate.graphics.image.new("images/playbit-logo")
  playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeCopy)
  img:draw(0, 0)
  pbAssert.IsImageSimilar()
end

function tests.DrawMode_Inverted()
  playdate.graphics.setColor(playdate.graphics.kColorWhite)
  playdate.graphics.fillRect(0, 0, 200, 240)
  playdate.graphics.setColor(playdate.graphics.kColorBlack)
  playdate.graphics.fillRect(200, 0, 200, 240)
  local img = playdate.graphics.image.new("images/playbit-logo")
  playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeInverted)
  img:draw(0, 0)
  pbAssert.IsImageSimilar()
end

function tests.DrawMode_DrawModeFillWhite()
  playdate.graphics.setColor(playdate.graphics.kColorWhite)
  playdate.graphics.fillRect(0, 0, 200, 240)
  playdate.graphics.setColor(playdate.graphics.kColorBlack)
  playdate.graphics.fillRect(200, 0, 200, 240)
  local img = playdate.graphics.image.new("images/playbit-logo")
  playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
  img:draw(0, 0)
  pbAssert.IsImageSimilar()
end

function tests.DrawMode_DrawModeFillBlack()
  playdate.graphics.setColor(playdate.graphics.kColorWhite)
  playdate.graphics.fillRect(0, 0, 200, 240)
  playdate.graphics.setColor(playdate.graphics.kColorBlack)
  playdate.graphics.fillRect(200, 0, 200, 240)
  local img = playdate.graphics.image.new("images/playbit-logo")
  playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)
  img:draw(0, 0)
  pbAssert.IsImageSimilar()
end

function tests.DrawMode_DrawModeFillWhiteTransparent()
  playdate.graphics.setColor(playdate.graphics.kColorWhite)
  playdate.graphics.fillRect(0, 0, 200, 240)
  playdate.graphics.setColor(playdate.graphics.kColorBlack)
  playdate.graphics.fillRect(200, 0, 200, 240)
  local img = playdate.graphics.image.new("images/playbit-logo")
  playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeWhiteTransparent)
  img:draw(0, 0)
  pbAssert.IsImageSimilar()
end

function tests.Pattern_IsDrawn()
  playdate.graphics.setPattern({0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 170, 85, 170, 85, 170, 85, 170, 85})
  playdate.graphics.fillRect(0, 0, 200, 240)
  pbAssert.IsImageSimilar()
end

function tests.Pattern_IsCleared()
  playdate.graphics.setPattern({0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 0x55, 0xAA, 170, 85, 170, 85, 170, 85, 170, 85})
  playdate.graphics.setColor(playdate.graphics.kColorBlack)
  playdate.graphics.fillRect(0, 0, 200, 240)
  pbAssert.IsImageSimilar()
end

return tests