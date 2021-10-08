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
    components[k].id = self:registerComponent(v.name, v.prototype)
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
  
  -- TODO: update systems

  if input.getButtonDown("debug_stats") then
    self.drawStats = not self.drawStats
  end

  input.update();

  perf.endFrameSample("update")
end

function App:draw()
  perf.beginFrameSample("render")

  -- TODO: render systems

  perf.endFrameSample("render")

  if self.drawStats then
    graphics.text(1, perf.getFps(), 0, 0, "right")
    graphics.text(1, perf.getFrameSample("update"), 0, 16, "right")
    graphics.text(1, perf.getFrameSample("render"), 0, 32, "right")
  end
end

function App:getSystemId(name)
  return self.systemNameToIdMap[name]
end

function App:registerSystem(name, system)
  local id = self.nextSystemId

  local componentIds = {}
  for i = 1, #system.components, 1 do
    local componentName = system.components[i]
    table.insert(componentIds, self:getComponentId(componentName))
  end
  self.systemComponentIds[id] = componentIds

  self.systemNameToIdMap[name] = id

  if system["update"] ~= nil then
    self.updateSystems[id] = system.update
  end

  if system["render"] ~= nil then
    self.renderSystems[id] = system.render
  end
  
  self.nextSystemId = self.nextSystemId + 1
  return id
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
  self.componentNameToIdMap[name] = id
  self.nextComponentId = self.nextComponentId + 1
  return id;
end

function App:addScene(newScene)
  table.insert(self.scenes, newScene)
  newScene.app = self
end

function App:changeScene(newScene)
  if self.scene ~= nil then
    self.scene:exit()
  end

  self.scene = newScene;

  if self.scene ~= nil then
    self.scene:enter()
  end
end

return App