local CollisionResolver = {}

CollisionResolver.name = "collision-detector"
CollisionResolver.perfSampleName = "__collision-detector"
CollisionResolver.components = { pb.components.Transform.name, pb.components.Collider.name }

function CollisionResolver.update(scene, entities)
  pb.perf.beginFrameSample(CollisionResolver.perfSampleName)
  -- TODO: sort entities into buckets based on collider layer
  -- so that collisions are only checked between entities on the same layer
  -- should it use a collision matrix, like Unity?

  -- clear contacts from last frame
  for i = 1, #entities, 1 do
    local entityId = entities[i]
    local collider = scene:getComponent(entityId, "collider")
    collider.contacts = {}
  end

  -- caclulate contacts
  for i = 1, #entities, 1 do
    local entityId = entities[i]
    local collider = scene:getComponent(entityId, "collider")
    if not collider.enabled then
      goto nextEntity
    end

    local transform = scene:getComponent(entityId, "transform")
    local x = transform.x + collider.x
    local y = transform.y + collider.x

    for j = #entities, 1, -1 do
      if i == j then
        -- once i=j is reached, we can break as we've already processed collisions from here
        break
      end

      local otherEntityId = entities[j]
      local otherCollider = scene:getComponent(otherEntityId, "collider")
      if not otherCollider.enabled then
        goto nextContact
      end

      local otherTransform = scene:getComponent(otherEntityId, "transform")
      local dx = x - (otherTransform.x + otherCollider.x)
      local dy = y - (otherTransform.y + otherCollider.y)

      local distance = math.sqrt((dx * dx) + (dy * dy))
      if distance < collider.radius + otherCollider.radius then
        table.insert(collider.contacts, otherEntityId)
        table.insert(otherCollider.contacts, entityId)
      end

      ::nextContact::
    end

    ::nextEntity::
  end
  pb.perf.endFrameSample(CollisionResolver.perfSampleName)
end

function CollisionResolver.renderDebug(scene, entities)
  for i = 1, #entities, 1 do
    local entityId = entities[i]
    local collider = scene:getComponent(entityId, "collider")
    local transform = scene:getComponent(entityId, "transform")

    local x = scene.camera.x + transform.x + collider.x
    local y = scene.camera.y + transform.y + collider.y
    if #collider.contacts > 0 then
      pb.debug.circle(x, y, collider.radius, true, -1, 1)
    else
      pb.debug.circle(x, y, collider.radius, false, -1, 1)
    end
  end
end

return CollisionResolver