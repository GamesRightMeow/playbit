local input = require("playbit.input")
local perf = require("playbit.perf")
local graphics = require("playbit.graphics")
local scene = require("playbit.scene")
local components = require("playbit.components")
local nameAllocator = require("playbit.systems.name-allocator")

local App = {}
App.__index = App

-- TODO: add settings argument
function App.new()
  local newApp = {
    drawStats = false,
    drawSystemDebug = 0,

    --! if LOVE2D then
    draw2x = true,
    --! end

    scene = nil,
    -- TODO: better name?
    systems = {},
    systemComponentIds = {},
    systemNameToIdMap = {},
    systemsToUpdate = {},
    systemsToRender = {},
    systemsToRenderDebug = {},
    nextSystemId = 1,
    componentTemplates = {},
    componentNameToIdMap = {},
    nextComponentId = 1,
  }
  setmetatable(newApp, App)
  return newApp
end

function App:load()
  -- register built in components
  for k,v in pairs(components) do
    self:registerComponent(v.name, v.template)
  end

  -- auto register this since order shouldn't really matter
  self:registerSystem(nameAllocator)

  if self["onLoad"] then
    self:onLoad()
  end

  --! if LOVE2D then
  love.graphics.setDefaultFilter("nearest", "nearest")
  --! end

  graphics.createFont(
    "playbit",
    "playbit/fonts/playbit.png",
    " abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!?-+/():;%&`_*#=[]'{}",
    1
  )
end

function App:joystickadded(joystick)
  input.handeGamepadAdded(joystick)
end

function App:joystickremoved(joystick)
  input.handeGamepadRemoved(joystick)
end

function App:gamepadpressed(joystick, button)
  input.handleGamepadPressed(joystick, button)
end

function App:gamepadreleased(joystick, button)
  input.handleGamepadReleased(joystick, button)
end

function App:keypressed(key)
  input.handleKeyPressed(key)
end

function App:keyreleased(key)
  input.handleKeyReleased(key)
end

function App:update()
  perf.beginFrameSample("update")
  
  self.scene:update()

  --! if LOVE2D then
  
  --! if DEBUG then
  -- TODO: expose stat toggle in playdates menu?
  if input.getButtonDown("debug_stats") then
    self.drawStats = not self.drawStats
  end

  if input.getButtonDown("toggle_debug_stats") then
    if self.drawSystemDebug == #self.systemsToRenderDebug then
      self.drawSystemDebug = 0
    else
      self.drawSystemDebug = self.drawSystemDebug + 1
    end
  end
  --! end
  
  if input.getButtonDown("toggle_window_size") then
    self.draw2x = not self.draw2x
    if self.draw2x then
      love.window.setMode(800, 480)
    else
      love.window.setMode(400, 240)
    end
  end
  --! end

  input.update();

  perf.endFrameSample("update")
end

function App:draw()
  perf.beginFrameSample("render")

  --! if LOVE2D then
  if self.draw2x then
    love.graphics.scale(2, 2)
  end
  --! end

  -- default to included playbit font
  graphics.setFont("playbit")

  self.scene:render()

  perf.endFrameSample("render")

  --! if DEBUG then
  -- TODO: consider putting these in dedicated system if more entity-specific features are added
  if self.drawStats and self.drawSystemDebug == 0 then
    graphics.setColor(1)
    graphics.rectangle(360, 0, 40, 33, true, 0)
    graphics.setColor(0)

    graphics.text("F", 361, 1, "left")
    graphics.text(perf.getFps(), 400, 1, "right")

    graphics.text("U", 361, 9, "left")
    graphics.text(perf.getFrameSample("update"), 400, 9, "right")

    graphics.text("R", 361, 17, "left")
    graphics.text(perf.getFrameSample("render"), 400, 17, "right")

    graphics.text("E", 361, 25, "left")
    graphics.text(self.scene.entityCount, 400, 25, "right")
  end
  --! end
end

--- Returns the system's id with the given name.
function App:getSystemId(name)
  return self.systemNameToIdMap[name]
end

--- Returns the system with the given name.
function App:getSystem(name)
  local id = self.systemNameToIdMap[name]
  return self.systems[id]
end

--- Returns the system with the given id.
function App:getSystemById(id)
  return self.systems[id]
end

--- Registers a system with the given name and options.
function App:registerSystem(system)
  pb.assert(self.systemNameToIdMap[system.name] == nil, "A system with the name '"..system.name.."' has already been registered!")

  -- allocate system id
  local systemId = self.nextSystemId
  self.nextSystemId = self.nextSystemId + 1

  -- convert component names to ids
  local componentIds = {}
  for i = 1, #system.components, 1 do
    local componentName = system.components[i]
    local componentId = self:getComponentId(componentName)
    pb.assert(componentId ~= nil, "System '"..system.name.."' requires a non-existent component '"..componentName.."'!")
    table.insert(componentIds, componentId)
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

  --! if DEBUG then
  if system.renderDebug ~= nil then
    table.insert(self.systemsToRenderDebug, systemId)
  end
  --! end
  
  return systemId
end

function App:getComponentId(name)
  return self.componentNameToIdMap[name]
end

function App:getComponentTemplate(id)
  return self.componentTemplates[id]
end

function App:registerComponent(name, template)
  pb.assert(self.componentNameToIdMap[name] == nil, "A component with the name '"..name.."' has already been registered!")
  local id = self.nextComponentId
  self.componentTemplates[id] = template
  setmetatable(template, {})
  template.__index = template
  self.componentNameToIdMap[name] = id
  self.nextComponentId = self.nextComponentId + 1
  return id;
end

--- Sets the active scene that the app is running.
function App:changeScene(newScene)
  if self.scene ~= nil then
    self.scene:exitInternal()
  end

  self.scene = newScene
  self.scene.app = self
  self.scene:startInternal()
  self.scene:enterInternal()
end

return App