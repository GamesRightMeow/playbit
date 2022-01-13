local components = require("playbit.components")

local System = {}

System.name = "physics"
System.components = { components.Velocity.name, components.Transform.name }

function System.update(scene, entities)
  for i = 1, #entities, 1 do
    local entity = entities[i]
    local velocity = scene:getComponent(entity, "velocity")
    local transform = scene:getComponent(entity, "transform")

    transform.x = transform.x + velocity.x * pb.util.deltaTime()
    transform.y = transform.y + velocity.y * pb.util.deltaTime()
  end
end

return System