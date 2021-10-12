local input = require("playbit.input")
local perf = require("playbit.perf");
local graphics = require("playbit.graphics");
local systems = require("playbit.systems");
local components = require("playbit.components");

local App = {}
setmetatable(App, {})
App.__index = App

-- TODO: add settings argument
function App.new()
  local newApp = {
    drawStats = false,
    scene = nil,
    -- TODO: better name?
    systemComponentIds = {},
    systemNameToIdMap = {},
    updateSystems = {},
    renderSystems = {},
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
    components[k].id = self:registerComponent(v.name, v.template)
  end

  -- register built in systems
  for k,v in pairs(systems) do
    systems[k].id = self:registerSystem(v.name, v)
  end

  if self["onLoad"] then
    self:onLoad()
  end
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

  for i = 1, #self.updateSystems, 1 do
    local systemId = self.updateSystems[i].id
    local entities = self.scene.systemEntityIds[systemId].entities
    self.updateSystems[i].update(self.scene, entities)
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

  for i = 1, #self.renderSystems, 1 do
    local systemId = self.renderSystems[i].id
    local entities = self.scene.systemEntityIds[systemId].entities
    self.renderSystems[i].render(self.scene, entities)
  end

  if self.scene["lateRender"] then
    self.scene.lateRender()
  end

  perf.endFrameSample("render")

  if self.drawStats then
    graphics.setColor(1)
    graphics.rectangle(350, 0, 50, 48, true)
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
function App:registerSystem(name, options)
  local systemId = self.nextSystemId

  local componentIds = {}
  for i = 1, #options.components, 1 do
    local componentName = options.components[i]
    table.insert(componentIds, self:getComponentId(componentName))
  end
  self.systemComponentIds[systemId] = componentIds

  self.systemNameToIdMap[name] = systemId

  if options["update"] ~= nil then
    table.insert(self.updateSystems, { id = systemId, update = options.update });
  end

  if options["render"] ~= nil then
    table.insert(self.renderSystems, { id = systemId, render = options.render });
  end
  
  self.nextSystemId = self.nextSystemId + 1
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