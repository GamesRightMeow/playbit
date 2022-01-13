local input = require("playbit.input")
local perf = require("playbit.perf")
local graphics = require("playbit.graphics")
local scene = require("playbit.scene")
local components = require("playbit.components")
local nameAllocator = require("playbit.systems.name-allocator")

local App = {}

App.drawStats = false
App.drawSystemDebug = 0

--! if LOVE2D then
App.draw2x = true
--! end

App.scene = nil
-- TODO: better name?
App.systems = {}
App.systemComponentIds = {}
App.systemNameToIdMap = {}
App.systemsToUpdate = {}
App.systemsToRender = {}
App.systemsToRenderDebug = {}
App.nextSystemId = 1
App.componentTemplates = {}
App.componentNameToIdMap = {}
App.nextComponentId = 1

-- TODO: add settings argument
function App.start()
  App.scene = nil
  App.systems = {}
  App.systemComponentIds = {}
  App.systemNameToIdMap = {}
  App.systemsToUpdate = {}
  App.systemsToRender = {}
  App.systemsToRenderDebug = {}
  App.nextSystemId = 1
  App.componentTemplates = {}
  App.componentNameToIdMap = {}
  App.nextComponentId = 1
end

function App.load()
  -- register built in components
  for k,v in pairs(components) do
    App.registerComponent(v.name, v.template)
  end

  -- auto register this since order shouldn't really matter
  App.registerSystem(nameAllocator)

  if App.onLoad then
    App.onLoad()
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

function App.joystickadded(joystick)
  input.handeGamepadAdded(joystick)
end

function App.joystickremoved(joystick)
  input.handeGamepadRemoved(joystick)
end

function App.gamepadpressed(joystick, button)
  input.handleGamepadPressed(joystick, button)
end

function App.gamepadreleased(joystick, button)
  input.handleGamepadReleased(joystick, button)
end

function App.keypressed(key)
  input.handleKeyPressed(key)
end

function App.keyreleased(key)
  input.handleKeyReleased(key)
end

function App.update()
  perf.beginFrameSample("__update")
  
  App.scene:update()

  --! if LOVE2D then
  
  --! if DEBUG then
  -- TODO: expose stat toggle in playdates menu?
  if input.getButtonDown("debug_stats") then
    App.drawStats = not App.drawStats
  end

  if input.getButtonDown("toggle_debug_stats") then
    if App.drawSystemDebug == #App.systemsToRenderDebug then
      App.drawSystemDebug = 0
    else
      App.drawSystemDebug = App.drawSystemDebug + 1
    end
  end
  --! end
  
  if input.getButtonDown("toggle_window_size") then
    App.draw2x = not App.draw2x
    if App.draw2x then
      love.window.setMode(800, 480)
    else
      love.window.setMode(400, 240)
    end
  end
  --! end

  input.update();

  perf.endFrameSample("__update")
end

function App.draw()
  perf.beginFrameSample("__render")

  --! if LOVE2D then
  if App.draw2x then
    love.graphics.scale(2, 2)
  end
  --! end

  -- default to included playbit font
  graphics.setFont("playbit")

  App.scene:render()

  perf.endFrameSample("__render")

  --! if DEBUG then
  -- TODO: consider putting these in dedicated system if more entity-specific features are added
  if App.drawStats and App.drawSystemDebug == 0 then
    graphics.setColor(1)
    graphics.rectangle(360, 0, 40, 33, true, 0)
    graphics.setColor(0)

    graphics.text("F", 361, 1, "left")
    graphics.text(perf.getFps(), 400, 1, "right")

    graphics.text("U", 361, 9, "left")
    graphics.text(perf.getFrameSample("__update"), 400, 9, "right")

    graphics.text("R", 361, 17, "left")
    graphics.text(perf.getFrameSample("__render"), 400, 17, "right")

    graphics.text("E", 361, 25, "left")
    graphics.text(App.scene.entityCount, 400, 25, "right")
  end
  --! end
end

--- Returns the system's id with the given name.
function App.getSystemId(name)
  return App.systemNameToIdMap[name]
end

--- Returns the system with the given name.
function App.getSystem(name)
  local id = App.systemNameToIdMap[name]
  return App.systems[id]
end

--- Returns the system with the given id.
function App.getSystemById(id)
  return App.systems[id]
end

--- Registers a system with the given name and options.
function App.registerSystem(system)
  pb.debug.assert(App.systemNameToIdMap[system.name] == nil, "A system with the name '"..system.name.."' has already been registered!")

  -- allocate system id
  local systemId = App.nextSystemId
  App.nextSystemId = App.nextSystemId + 1

  -- convert component names to ids
  local componentIds = {}
  for i = 1, #system.components, 1 do
    local componentName = system.components[i]
    local componentId = App.getComponentId(componentName)
    pb.debug.assert(componentId ~= nil, "System '"..system.name.."' requires a non-existent component '"..componentName.."'!")
    table.insert(componentIds, componentId)
  end
  App.systemComponentIds[systemId] = componentIds

  -- register system
  App.systemNameToIdMap[system.name] = systemId
  App.systems[systemId] = system

  if system.update ~= nil then
    table.insert(App.systemsToUpdate, systemId)
  end

  if system.render ~= nil then
    table.insert(App.systemsToRender, systemId)
  end

  --! if DEBUG then
  if system.renderDebug ~= nil then
    table.insert(App.systemsToRenderDebug, systemId)
  end
  --! end
  
  return systemId
end

function App.getComponentId(name)
  return App.componentNameToIdMap[name]
end

function App.getComponentTemplate(id)
  return App.componentTemplates[id]
end

function App.registerComponent(name, template)
  pb.debug.assert(App.componentNameToIdMap[name] == nil, "A component with the name '"..name.."' has already been registered!")
  local id = App.nextComponentId
  App.componentTemplates[id] = template
  setmetatable(template, {})
  template.__index = template
  App.componentNameToIdMap[name] = id
  App.nextComponentId = App.nextComponentId + 1
  return id
end

--- Sets the active scene that the app is running.
function App.changeScene(newScene)
  if App.scene ~= nil then
    App.scene:exitInternal()
  end

  App.scene = newScene
  App.scene:startInternal()
  App.scene:enterInternal()
end

return App