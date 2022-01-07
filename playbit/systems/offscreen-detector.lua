local components = require("playbit.components")

local System = {}

System.name = "offscreen-detector"
System.components = { components.OffscreenDetector.name, components.Transform.name, components.Graphic.name }

function System.update(scene, entities)
  for i = 1, #entities, 1 do
    local entityId = entities[i]

    local transform = scene:getComponent(entityId, components.Transform.name)
    local detector = scene:getComponent(entityId, components.OffscreenDetector.name)
    local graphic = scene:getComponent(entityId, components.Graphic.name)

    local distanceX = -scene.camera.x * graphic.scrollX - transform.x
    local distanceY = -scene.camera.y * graphic.scrollY - transform.y

    if distanceX < -400 then
      -- past right edge
      detector.x = 1
      detector.isOffscreen = true
    elseif distanceX > 0 then
      -- past left edge
      detector.x = -1
      detector.isOffscreen = true
    elseif distanceY < -240 then
      -- past bottom edge
      detector.y = 1
      detector.isOffscreen = true
    elseif distanceY > 0 then
      -- past top edge
      detector.y = -1
      detector.isOffscreen = true
    else
      detector.x = 0
      detector.y = 0
      detector.isOffscreen = false
    end

    if detector.isOffscreen and detector.deleteWhenOffScreen then
      scene:removeEntity(entityId)
    end
  end
end

return System