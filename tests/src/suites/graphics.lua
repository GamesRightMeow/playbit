local tests = {}

function tests.drawCircle()
  playdate.graphics.clear()
  playdate.graphics.fillCircleAtPoint(200, 50, 10)
  playdate.graphics.drawCircleAtPoint(200, 10, 10)
  pbAssert.IsImageSimilar("graphics_drawCircle")
end

function tests.drawRect()
  playdate.graphics.clear()
  playdate.graphics.fillRect(200, 0, 10, 10)
  playdate.graphics.drawRect(200, 50, 10, 10)
  pbAssert.IsImageSimilar("graphics_drawRect")
end

function tests.clear()
  playdate.graphics.clear()
  playdate.graphics.fillRect(0, 0, 400, 240)
  playdate.graphics.clear()
  pbAssert.IsImageSimilar("graphics_clear")
  playdate.graphics.clear(0)
  pbAssert.IsImageSimilar("graphics_clear_white")
  playdate.graphics.clear(1)
  pbAssert.IsImageSimilar("graphics_clear_black")
end

function tests.drawLine()
  playdate.graphics.clear()
  playdate.graphics.drawLine(0, 0, 400, 240)
  playdate.graphics.setLineWidth(1)
  playdate.graphics.drawLine(0, 50, 400, 50)
  playdate.graphics.setLineWidth(10)
  playdate.graphics.drawLine(0, 100, 400, 100)
  playdate.graphics.setLineWidth(1)
  pbAssert.IsImageSimilar("graphics_line")
end

function tests.drawArc()
  playdate.graphics.clear()
  playdate.graphics.drawArc(50, 50, 20, 0, 360)
  playdate.graphics.drawArc(50, 100, 20, 0, 90)
  playdate.graphics.drawArc(50, 150, 20, 0, 180)
  pbAssert.IsImageSimilar("graphics_arc")
end

return tests