local EntityArray = {}
EntityArray.__index = EntityArray

--- Creates a new EntityArray instance.
function EntityArray.new()
  local newEntityArray = {
    entities = {},
    idToIndexMap = {},
    indexToIdMap = {},
  }
  setmetatable(newEntityArray, EntityArray)
  return newEntityArray
end

--- Returns true if the specified entity exists in this array.
function EntityArray:contains(entityId)
  return self.idToIndexMap[entityId] ~= nil
end

--- Adds an entity.
function EntityArray:add(entityId)
  if self.idToIndexMap[entityId] ~= nil then
    -- entity already added
    return
  end

  local index = #self.entities + 1
  self.idToIndexMap[entityId] = index
  self.indexToIdMap[index] = entityId
  table.insert(self.entities, entityId)
end

--- Removes an entity.
function EntityArray:remove(entityId)
  local index = self.idToIndexMap[entityId]
  if index == nil then
    -- entity does not exist
    return
  end
  
  if #self.entities == 1 then
    self.idToIndexMap[entityId] = nil
    self.indexToIdMap[index] = nil
    self.entities[index] = nil
  else
    -- move last entity in list to deleted entity's position
    local lastIndex = #self.entities
    local lastId = self.indexToIdMap[lastIndex]
    self.entities[index] = self.entities[lastIndex]

    -- remap id/index
    self.idToIndexMap[lastId] = index
    self.indexToIdMap[index] = lastId

    -- delete last element
    self.idToIndexMap[entityId] = nil
    self.indexToIdMap[lastIndex] = nil
    self.entities[lastIndex] = nil
  end
end

return EntityArray;