local Debug = {}

function Debug.assert(value, message)
  --! if ASSERT then
  assert(value, message)
  --! end
end

Debug.debugShapes = {}

function Debug.drawLine(x1, y1, x2, y2, color, duration)
  table.insert(Debug.debugShapes, { 
    type = "line", 
    x1 = x1, y1 = y1, 
    x2 = x2, y2 = y2, 
    color = color, 
    duration = duration
  })
end

return Debug