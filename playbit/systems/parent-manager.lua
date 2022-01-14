local System = {}

System.name = "parent-manager"
System.components = { pb.components.Parent.name, pb.components.Transform.name }

local function setPosition(scene, entity, processedEntities)
  if processedEntities[entity] then
    -- already processed this entity, skip
    return
  end

  local parent = scene:getComponent(entity, "parent")
  local transform = scene:getComponent(entity, "transform")

  local otherEntity = parent.entity
  if parent.entity == -1 then
    otherEntity = scene:findEntity(parent.name)
    if otherEntity == -1 then
      -- parent entity not found, skip
      -- TODO: runtime error?
      return false
    end
  end

  local otherParent = scene:getComponent(otherEntity, "parent")
  if otherParent ~= nil then
    setPosition(scene, otherEntity, processedEntities)
  end

  local otherTransform = scene:getComponent(otherEntity, "transform")
  transform.x = otherTransform.x + parent.x
  transform.y = otherTransform.y + parent.y
  
  processedEntities[entity] = true


  return true
end

function System.update(scene, entities)
  local processedEntities = {}

  for i = 1, #entities, 1 do
    local entity = entities[i]
    if not processedEntities[entity] then
      -- only set position if entity wasn't already processed
      setPosition(scene, entity, processedEntities)
    end
  end
end

return System