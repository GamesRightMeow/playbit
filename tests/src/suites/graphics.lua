local tests = {}

function tests.FillCircleAtPoint_IsDrawn()
  playdate.graphics.fillCircleAtPoint(200, 50, 10)
  pbAssert.IsImageSimilar("graphics_fillCircleAtPoint")
end

function tests.DrawCircleAtPoint_IsDrawn()
  playdate.graphics.drawCircleAtPoint(200, 10, 10)
  pbAssert.IsImageSimilar("graphics_drawCircleAtPoint")
end

function tests.FillRect_IsDrawn()
  playdate.graphics.fillRect(200, 0, 10, 10)
  pbAssert.IsImageSimilar("graphics_fillRect")
end

function tests.DrawRect_IsDrawn()
  playdate.graphics.drawRect(200, 50, 10, 10)
  pbAssert.IsImageSimilar("graphics_drawRect")
end

function tests.Clear_DoesClear()
  playdate.graphics.fillRect(0, 0, 400, 240)
  playdate.graphics.clear()
  pbAssert.IsImageSimilar("graphics_clear")
  playdate.graphics.clear(0)
  pbAssert.IsImageSimilar("graphics_clear_white")
  playdate.graphics.clear(1)
  pbAssert.IsImageSimilar("graphics_clear_black")
end

function tests.DrawLine_IsDrawn()
  playdate.graphics.drawLine(0, 0, 400, 240)
  playdate.graphics.setLineWidth(1)
  playdate.graphics.drawLine(0, 50, 400, 50)
  playdate.graphics.setLineWidth(10)
  playdate.graphics.drawLine(0, 100, 400, 100)
  playdate.graphics.setLineWidth(1)
  pbAssert.IsImageSimilar("graphics_line")
end

function tests.DrawArc_IsDrawn()
  playdate.graphics.drawArc(50, 50, 20, 0, 360)
  playdate.graphics.drawArc(50, 100, 20, 0, 90)
  playdate.graphics.drawArc(50, 150, 20, 0, 180)
  pbAssert.IsImageSimilar("graphics_arc")
end

function tests.DrawPixel_IsDrawn()
  playdate.graphics.clear()
  playdate.graphics.drawPixel(200, 120)
  pbAssert.IsImageSimilar("graphics_drawPixel")
end

function tests.DrawText_IsDrawn()
  playdate.graphics.drawText("hello world", 0, 0)
  -- TODO: test other params when implemented
  pbAssert.IsImageSimilar("graphics_drawText")
end

function tests.DrawTextAligned_IsDrawn()
  playdate.graphics.drawTextAligned("hello world", 0, 0, 0)
  playdate.graphics.drawTextAligned("foobar", 0, 20, 1)
  playdate.graphics.drawTextAligned("playdate", 0, 40, 2)
  -- TODO: test other params when implemented
  pbAssert.IsImageSimilar("graphics_drawTextAligned")
end

function tests.Context_IsNotDrawn()
  local img = playdate.graphics.image.new(400, 200)
  playdate.graphics.pushContext(img)
  playdate.graphics.fillRect(200, 120, 20, 20)
  playdate.graphics.popContext()
  pbAssert.IsImageSimilar("graphics_context_notdrawn")
end

function tests.Context_IsDrawn()
  local img = playdate.graphics.image.new(400, 200)
  playdate.graphics.pushContext(img)
  playdate.graphics.fillRect(200, 120, 20, 20)
  playdate.graphics.popContext()
  img:draw(0, 0)
  pbAssert.IsImageSimilar("graphics_context_IsDrawn")
end

function tests.FontSize_IsReturned()
  local size = playdate.graphics.getTextSize("hello world")
  pbAssert.AreEqual(size, 88)
end

return tests