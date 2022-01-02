local components = require("playbit.components")

local System = {}

System.name = "physics"
System.components = { components.Velocity.name, components.Transform.name }

function System.update(scene, entities)
  for i = 1, #entities, 1 do
    local entity = entities[i]
    local velocity = scene:getComponent(entity, "velocity")
    local transform = scene:getComponent(entity, "transform")

    if math.abs(velocity.x) < 0.001 then
      velocity.x = 0
    end

    if math.abs(velocity.y) < 0.001 then
      velocity.y = 0
    end

    transform.x = transform.x + velocity.x * pb.util.deltaTime()
    transform.y = transform.y - velocity.y * pb.util.deltaTime()
  end
end

return System