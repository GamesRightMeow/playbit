local ComponentArray = {}
ComponentArray.__index = ComponentArray

--- creates a new ComponentArray instance
function ComponentArray.new()
  local newComponentArray = {
    components = {},
    idToIndexMap = {},
    indexToIdMap = {},
  }
  setmetatable(newComponentArray, ComponentArray)
  return newComponentArray
end

--- adds a component for the specified entity
function ComponentArray:add(entityId, component)
  local index = #self.components + 1
  self.idToIndexMap[entityId] = index
  self.indexToIdMap[index] = entityId
  table.insert(self.components, component)
end

--- removes a component for the specified entity
function ComponentArray:remove(entityId)
  local index = self.idToIndexMap[entityId]
  if index == nil then
    return
  end
  
  if #self.components == 1 then
    self.idToIndexMap[entityId] = nil
    self.indexToIdMap[index] = nil
    self.components[index] = nil
  else
    -- move last entity in list to deleted entity's position
    local lastIndex = #self.components
    local lastId = self.indexToIdMap[lastIndex]
    self.components[index] = self.components[lastIndex]

    -- remap id/index
    self.idToIndexMap[lastId] = index
    self.indexToIdMap[index] = lastId

    -- delete last element
    self.idToIndexMap[entityId] = nil
    self.indexToIdMap[lastIndex] = nil
    self.components[lastIndex] = nil
  end
end

--- gets the component for the specified entity
function ComponentArray:get(entityId)
  local index = self.idToIndexMap[entityId]
  if index == nil then
    -- entity does not have component
    return nil
  end

  return self.components[index]
end

--- Returns the entity id of the owner of the component at the specified index.
function ComponentArray:getOwner(componentIndex)
  return self.indexToIdMap[componentIndex]
end

return ComponentArray;