local components = require("playbit.components")
local nameAllocator = require("playbit.systems.name-allocator")
local componentArray = require("playbit.component-array")
local entityArray = require("playbit.entity-array")
local perf = require("playbit.perf")

local Scene = {}
Scene.__index = Scene

-- creates a new Scene instance
function Scene.new()
  local newScene = {
    app = nil,
    hasStarted = false,
    newEntityId = 1,
    entityCount = 0,
    entitiesToRemove = nil,
    componentsToAdd = nil,
    componentsToRemove = nil,
    dirtyEntities = nil,
    componentArrays = {},
    availableEntityIds = {},
    systemEntityIds = {},
    camera = { x = 0, y = 0 }
  }
  setmetatable(newScene, Scene)

  return newScene
end

function Scene:startInternal()
  if self.hasStarted then
    return
  end

  -- create component lists
  for componentId = 1, self.app.nextComponentId - 1, 1 do
    self.componentArrays[componentId] = componentArray.new()
  end

  -- create system entity lists
  for systemId = 1, self.app.nextSystemId - 1, 1 do
    self.systemEntityIds[systemId] = entityArray.new()
  end

  if self.start then
    self:start()
  end

  self.hasStarted = true
end

function Scene:enterInternal()
  -- TODO: internal enter?

  if self.enter then
    self:enter()
  end
end

function Scene:exitInternal()
  -- TODO: internal exit?

  if self.exit then
    self:exit()
  end
end

local function addPendingComponents(self)
  if not self.componentsToAdd then
    return
  end

  if not self.dirtyEntities then
    self.dirtyEntities = {}
  end

  for k,v in pairs(self.componentsToAdd) do
    local entityId = k

    -- add pending components
    for i = 1, #self.componentsToAdd[entityId], 1 do
      local componentId = self.componentsToAdd[entityId][i].id
      local componentData = self.componentsToAdd[entityId][i].data
      self.componentArrays[componentId]:add(entityId, componentData)
    end

    -- mark as dirty so entity can be added/removed from systems
    self.dirtyEntities[entityId] = true
  end

  self.componentsToAdd = nil
end

local function removePendingComponents(self)
  if not self.componentsToRemove then
    return
  end

  if not self.dirtyEntities then
    self.dirtyEntities = {}
  end

  for k,v in pairs(self.componentsToRemove) do
    local entityId = k

    -- remove pending components
    for i = 1, #self.componentsToRemove[entityId], 1 do
      local componentId = self.componentsToRemove[entityId][i].id
      self.componentArrays[componentId]:remove(entityId)
    end

    -- mark as dirty so entity can be added/removed from systems
    self.dirtyEntities[entityId] = true
  end

  self.componentsToRemove = nil
end

local function removeEntities(self)
  if not self.entitiesToRemove then
    return
  end

  if not self.dirtyEntities then
    self.dirtyEntities = {}
  end

  for k,v in pairs(self.entitiesToRemove) do
    local entityId = k
    table.insert(self.availableEntityIds, entityId)
    self.entityCount = self.entityCount - 1
    self.dirtyEntities[entityId] = true
  end

  self.entitiesToRemove = nil
end

local function processDirtyEntities(self)
  if not self.dirtyEntities then
    return
  end

  for k,v in pairs(self.dirtyEntities) do
    local entityId = k
    for systemId = 1, #self.app.systemComponentIds, 1 do
      local systemComponents = self.app.systemComponentIds[systemId]
      -- TODO: this adds/removes entities from every system when dirty - need to only do this to affected ones
      if self:hasComponentIds(entityId, systemComponents) then
        self.systemEntityIds[systemId]:add(entityId)
      else
        self.systemEntityIds[systemId]:remove(entityId)
      end
    end
  end

  self.dirtyEntities = nil
end

function Scene:update()
  addPendingComponents(self)
  removePendingComponents(self)
  removeEntities(self)
  processDirtyEntities(self)

  -- update systems
  local systemsToUpdate = self.app.systemsToUpdate
  for i = 1, #systemsToUpdate, 1 do
    local systemId = systemsToUpdate[i]
    local entities = self.systemEntityIds[systemId].entities
    local system = self.app:getSystemById(systemId)
    system.update(self, entities)
  end
end

function Scene:render()
  -- render systems
  local systemsToRender = self.app.systemsToRender
  for i = 1, #systemsToRender, 1 do
    local systemId = systemsToRender[i]
    local entities = self.systemEntityIds[systemId].entities
    local system = self.app:getSystemById(systemId)
    system.render(self, entities)
  end

  --! if DEBUG then
  if self.app.drawStats and self.app.drawSystemDebug > 0 then
    local systemId = self.app.systemsToRenderDebug[self.app.drawSystemDebug]
    local entities = self.systemEntityIds[systemId].entities
    local system = self.app:getSystemById(systemId)
    system.renderDebug(self, entities)

    pb.graphics.setColor(0)
    pb.graphics.rectangle(0, 0, 400, 10, true)
    pb.graphics.setColor(1)
    pb.graphics.text(system.name.." "..perf.getFrameSample(system.perfSampleName).."ms", 200, 0, "center")
  end

  local count = #pb.debug.debugShapes 
  for i = count, 1, -1 do
    local shape = pb.debug.debugShapes[i]
    if shape.duration <= 0 then
      table.remove(pb.debug.debugShapes, i)
    else
      shape.duration = shape.duration - pb.util.deltaTime()
      if shape.type == "line" then
        pb.graphics.setColor(shape.color)
        -- TODO: allow for non-camera aligned shapes
        pb.graphics.line(
          self.camera.x + shape.x1, self.camera.y + shape.y1, 
          self.camera.x + shape.x2, self.camera.y + shape.y2, 
          0.5)
      end
      -- TODO: other shapes
    end
  end
  
  --! end
end

--- Returns all entities that have the specified component.
function Scene:getEntitiesWithComponent(componentName)
  local componentId = self.app:getComponentId(componentName)
  local count = #self.componentArrays[componentId].components

  local owners = {}
  for i = 1, count, 1 do  
    local ownerEntityId = self.componentArrays[componentId]:getOwner(i)
    table.insert(owners, ownerEntityId)
  end

  return owners 
end

--- Retrieves all components of the specified type.
function Scene:getComponents(componentName)
  local componentId = self.app:getComponentId(componentName)
  return self:getComponentsById(componentId)
end

--- Retrieves all components of the specified type by id.
function Scene:getComponentsById(componentId)
  return self.componentArrays[componentId].components
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

--- Adds multiple components to an entity.
function Scene:addComponents(entityId, components)
  for k,v in pairs(components) do
    self:addComponent(entityId, k, v)
  end
end

--- adds a component to an entity
function Scene:addComponent(entityId, componentName, data)
  local componentId = self.app:getComponentId(componentName)
  pb.debug.assert(componentId, "Component '"..componentName.."' does not exist.")
  self:addComponentById(entityId, componentId, data)
end

--- adds a component to an entity
function Scene:addComponentById(entityId, componentId, data)
  -- make template the meta table of new data
  local template = self.app:getComponentTemplate(componentId)
  setmetatable(data, template)

  -- add to queue to be added next frame
  if not self.componentsToAdd then
    self.componentsToAdd = {}
  end
  if not self.componentsToAdd[entityId] then
    self.componentsToAdd[entityId] = {}
  end
  table.insert(self.componentsToAdd[entityId], { id = componentId, data = data })
end

--- removes a component from an entity.
function Scene:removeComponent(entityId, componentName)
  local componentId = self.app:getComponentId(componentName)
  self:removeComponentById(entityId, componentId)
end

--- removes a component from an entity.
function Scene:removeComponentById(entityId, componentId)
  -- add to queue to be removed next frame
  if not self.componentsToRemove then
    self.componentsToRemove = {}
  end
  if not self.componentsToRemove[entityId] then
    self.componentsToRemove[entityId] = {}
  end
  table.insert(self.componentsToRemove[entityId], { id = componentId })
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
  local nameSystemId = self.app:getSystemId(nameAllocator.name)
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
  local entityId = -1
  if #self.availableEntityIds > 0 then
    -- use a recycled entity id if possible
    entityId = table.remove(self.availableEntityIds)
  else
    -- otherwise generate a new one
    entityId = self.newEntityId
    self.newEntityId = self.newEntityId + 1
  end

  if components then
    self:addComponents(entityId, components)
  end

  self.entityCount = self.entityCount + 1

  return entityId
end

--- removes the entity with the specified id.
function Scene:removeEntity(id)
  for i = 1, #self.componentArrays, 1 do
    self:removeComponentById(id, i)
  end

  if not self.entitiesToRemove then
    self.entitiesToRemove = {}
  end
  self.entitiesToRemove[id] = true
end

return Scene