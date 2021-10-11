local components = require("playbit.components")
local systems = require("playbit.systems")
local componentArray = require("playbit.component-array")
local entityArray = require("playbit.entity-array")

local Scene = {}
setmetatable(Scene, {})
Scene.__index = Scene

-- creates a new Scene instance
function Scene.new(app, maxEntities)
  if maxEntities == nil then
    maxEntities = 1000
  end

  local newScene = {
    -- TODO: make max entities configurable
    maxEntities = maxEntities,
    app = app,
    entityCount = 0,
    componentArrays = {},
    availableEntityIds = {},
    systemEntityIds = {},
  }
  setmetatable(newScene, Scene)

  -- allocate entity ids
  for i = 1, newScene.maxEntities, 1 do
    newScene.availableEntityIds[i] = newScene.maxEntities - i
  end

  -- create component lists
  for componentId = 1, newScene.app.nextComponentId - 1, 1 do
    newScene.componentArrays[componentId] = componentArray.new()
  end

  -- create system entity lists
  for systemId = 1, newScene.app.nextSystemId - 1, 1 do
    newScene.systemEntityIds[systemId] = entityArray.new()
  end

  return newScene
end

function Scene:enter()
  -- TODO
end

function Scene:exit()
  -- TODO
end

--- retrieves a component from an entity
function Scene:getComponent(entityId, componentName)
  local componentId = self.app:getComponentId(componentName)
  return self:getComponentById(entityId, componentId)
end

--- retrieves a component from an entity
function Scene:getComponentById(entityId, componentId)
  return self.componentArrays[componentId]:get(entityId)
end

--- adds a component to an entity
function Scene:addComponent(entityId, componentName, data)
  local componentId = self.app:getComponentId(componentName)
  self:addComponentById(entityId, componentId, data)
end

--- adds a component to an entity
function Scene:addComponentById(entityId, componentId, data)
  -- make template the meta table of new data
  local template = self.app:getComponentTemplate(componentId)
  setmetatable(data, template)

  -- add component
  self.componentArrays[componentId]:add(entityId, data)

  -- add entity to systems based on component signature
  for systemId = 1, #self.app.systemComponentIds, 1 do
    local componentIds = self.app.systemComponentIds[systemId]
    if self:hasComponentIds(entityId, componentIds) then
      self.systemEntityIds[systemId]:add(entityId)
    end
  end
end

--- removes a component from an entity.
function Scene:removeComponent(entityId, componentName)
  local componentId = self.app:getComponentId(componentName)
  self:removeComponentById(entityId, componentId)
end

--- removes a component from an entity.
function Scene:removeComponentById(entityId, componentId)
  self.componentArrays[componentId]:remove(entityId)

  for systemId = 1, #self.app.systemComponentIds, 1 do
    local componentIds = self.app.systemComponentIds[systemId]
    if not self:hasComponentIds(entityId, componentIds) then
      self.systemEntityIds[systemId]:remove(entityId)
    end
  end
end

--- returns true if the specified entity has the specified component
function Scene:hasComponent(entityId, componentName)
  local componentId = self.app:getComponentId(componentName)
  return self.componentArrays[componentId]:get(entityId) ~= nil
end

--- returns true if the specified entity has the specified component
function Scene:hasComponentId(entityId, componentId)
  return self.componentArrays[componentId]:get(entityId) ~= nil
end

-- returns true if entity has all specified components
function Scene:hasComponents(entityId, componentNames)
  for i = 1, #componentNames, 1 do
    local componentId = self.app:getComponentId(componentNames[i])
    if self.componentArrays[componentId]:get(entityId) == nil then
      return false
    end
  end
  return true
end

-- returns true if entity has all specified components
function Scene:hasComponentIds(entityId, componentIds)
  for i = 1, #componentIds, 1 do
    local componentId = componentIds[i]
    if self.componentArrays[componentId]:get(entityId) == nil then
      return false
    end
  end
  return true
end

--- returns the id of the first entity found with the specified name, or '-1' if it doesnt exist.
function Scene:findEntity(name)
  local nameSystemId = self.app:getSystemId(systems.Name.name)
  local nameComponentId = self.app:getComponentId(components.Name.name)
  local entityIds = self.systemEntityIds[nameSystemId].entities
  for i = 1, #entityIds, 1 do
    local nameComponent = self:getComponentById(entityIds[i], nameComponentId)
    if nameComponent.name == name then
      return entityIds[i]
    end
  end

  return -1
end

--- allocates a new entity with the specified components and returns the id.
function Scene:addEntity(components)
  -- init new entity
  local entityId = table.remove(self.availableEntityIds)
  self.entityCount = self.entityCount + 1

  -- add components
  if components ~= nil then
    for k,v in pairs(components) do
      self:addComponent(entityId, k, v)
    end
  end

  return entityId
end

--- removes the entity with the specified id.
function Scene:removeEntity(id)
  for i = 1, #self.componentArrays, 1 do
    self.componentArrays[i]:remove(id)
  end

  table.insert(self.availableEntityIds, id)
  self.entityCount = self.entityCount - 1

  for i = 1, #self.systemEntityIds, 1 do
    self.systemEntityIds[i]:remove(id)
  end
end

return Scene