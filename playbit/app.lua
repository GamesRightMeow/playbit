local input = require("playbit.input")
local perf = require("playbit.perf")
local graphics = require("playbit.graphics")
local components = require("playbit.components")
local nameAllocator = require("playbit.systems.name-allocator")

local App = {}
setmetatable(App, {})
App.__index = App

-- TODO: add settings argument
function App.new()
  local newApp = {
    drawStats = false,
    scene = nil,
    -- TODO: better name?
    systems = {},
    systemComponentIds = {},
    systemNameToIdMap = {},
    systemsToUpdate = {},
    systemsToRender = {},
    nextSystemId = 1,
    componentTemplates = {},
    componentNameToIdMap = {},
    nextComponentId = 1,
    scenes = {},
  }
  setmetatable(newApp, App)
  return newApp
end

function App:load()
  -- register built in components
  for k,v in pairs(components) do
    self:registerComponent(v.name, v.template)
  end

  -- auto register this since order should really matter
  self:registerSystem(nameAllocator)

  if self["onLoad"] then
    self:onLoad()
  end

  love.graphics.setDefaultFilter("nearest", "nearest")
end

function App:keypressed(key)
  input.handleKeyPressed(key)
end

function App:keyreleased(key)
  input.handleKeyReleased(key)
end

function App:update()
  perf.beginFrameSample("update")
  
  if self.scene["update"] then
    self.scene.update()
  end

  for i = 1, #self.systemsToUpdate, 1 do
    local systemId = self.systemsToUpdate[i]
    local entities = self.scene.systemEntityIds[systemId].entities
    local system = self.systems[systemId]
    system.update(self.scene, entities)
  end

  if self.scene["lateUpdate"] then
    self.scene.lateUpdate()
  end

  if input.getButtonDown("debug_stats") then
    self.drawStats = not self.drawStats
  end

  input.update();

  perf.endFrameSample("update")
end

function App:draw()
  perf.beginFrameSample("render")

  if self.scene["render"] then
    self.scene.render()
  end

  for i = 1, #self.systemsToRender, 1 do
    local systemId = self.systemsToRender[i]
    local entities = self.scene.systemEntityIds[systemId].entities
    local system = self.systems[systemId]
    system.render(self.scene, entities)
  end

  if self.scene["lateRender"] then
    self.scene.lateRender()
  end

  perf.endFrameSample("render")

  if self.drawStats then
    graphics.setColor(1)
    graphics.rectangle(350, 0, 50, 48, true, 0)
    graphics.setColor(0)
    graphics.text(perf.getFps(), 0, 0, "right")
    graphics.text(perf.getFrameSample("update"), 0, 16, "right")
    graphics.text(perf.getFrameSample("render"), 0, 32, "right")
  end
end

function App:getSystemId(name)
  return self.systemNameToIdMap[name]
end

--- Registers a system with the given name and options.
function App:registerSystem(system)
  -- allocate system id
  local systemId = self.nextSystemId
  self.nextSystemId = self.nextSystemId + 1

  -- convert component names to ids
  local componentIds = {}
  for i = 1, #system.components, 1 do
    local componentName = system.components[i]
    table.insert(componentIds, self:getComponentId(componentName))
  end
  self.systemComponentIds[systemId] = componentIds

  -- register system
  self.systemNameToIdMap[system.name] = systemId
  self.systems[systemId] = system

  if system.update ~= nil then
    table.insert(self.systemsToUpdate, systemId)
  end

  if system.render ~= nil then
    table.insert(self.systemsToRender, systemId)
  end
  
  return systemId
end

function App:getComponentId(name)
  return self.componentNameToIdMap[name]
end

function App:getComponentTemplate(id)
  return self.componentTemplates[id]
end

function App:registerComponent(name, template)
  local id = self.nextComponentId
  self.componentTemplates[id] = template
  setmetatable(template, {})
  template.__index = template
  self.componentNameToIdMap[name] = id
  self.nextComponentId = self.nextComponentId + 1
  return id;
end

function App:addScene(newScene)
  table.insert(self.scenes, newScene)
  newScene.app = self
end

function App:changeScene(newScene)
  if self.scene ~= nil and self.scene["enter"] then
    self.scene:exit()
  end

  self.scene = newScene;

  if self.scene ~= nil and self.scene["enter"] then
    self.scene:enter()
  end
end

return App