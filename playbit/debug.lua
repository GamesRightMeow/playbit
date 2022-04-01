local module = {}

local function drawLine(x1, y1, x2, y2, color)
  --! if LOVE2D then
  -- render red in love, because we can and its easier to see
  love.graphics.setColor(1, 0.1, 0.1)
  --! else
  pb.graphics.setColor(color)
  --! end

  -- TODO: allow for non-camera aligned shapes
  local camera = pb.app.scene.camera
  pb.graphics.line(
    camera.x + x1, camera.y + y1, 
    camera.x + x2, camera.y + y2, 
    0.5)
end

local function drawCircle(x, y, radius, filled, color)
  --! if LOVE2D then
  -- render red in love, because we can and its easier to see
  love.graphics.setColor(1, 0.1, 0.1)
  --! else
  pb.graphics.setColor(color)
  --! end

  -- TODO: allow for non-camera aligned shapes
  pb.graphics.circle(x, y, radius, filled)
end

function module.assert(value, message)
  --! if ASSERT then
  assert(value, message)
  --! end
end

--! if DEBUG then
module.debugShapes = {}
--! end

function module.circle(x, y, radius, filled, duration, color)
  --! if DEBUG then
  if not color then
    color = 1
  end

  if duration and duration ~= -1 then
    -- with duration
    table.insert(module.debugShapes, { 
      type = "circle", 
      x = x, y = y, 
      radius = radius, 
      filled = filled, 
      color = color, 
      duration = duration
    })
  else
    -- immediate
    drawCircle(x, y, radius, filled, color)
  end
  --! end
end

function module.line(x1, y1, x2, y2, duration, color)
  --! if DEBUG then
  if not color then
    color = 1
  end
  
  if duration and duration ~= -1 then
    -- with duration
    table.insert(module.debugShapes, { 
      type = "line", 
      x1 = x1, y1 = y1, 
      x2 = x2, y2 = y2, 
      color = color, 
      duration = duration
    })
  else
    -- immediate
    drawLine(x1, y1, x2, y2, color)
  end
  --! end
end

function module.renderDebugShapes()
  --! if DEBUG then
  local count = #module.debugShapes 
  for i = count, 1, -1 do
    local shape = module.debugShapes[i]
    if shape.duration <= 0 then
      table.remove(module.debugShapes, i)
    else
      shape.duration = shape.duration - pb.time.deltaTime()
      if shape.type == "line" then
        drawLine(shape.x1, shape.y1, shape.x2, shape.y2, shape.color)
      elseif shape.type == "circle" then
        drawCircle(shape.x, shape.y, shape.radius, shape.filled, shape.color)
      end
      -- TODO: other shapes
    end
  end
  --! end
end

return module