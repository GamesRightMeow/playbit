local System = {}

System.name = "physics"
System.components = { pb.components.Velocity.name, pb.components.Transform.name }

function System.update(scene, entities)
  for i = 1, #entities, 1 do
    local entity = entities[i]
    local velocity = scene:getComponent(entity, "velocity")
    local transform = scene:getComponent(entity, "transform")

    transform.x = transform.x + velocity.x * pb.time.deltaTime()
    transform.y = transform.y + velocity.y * pb.time.deltaTime()
  end
end

return System