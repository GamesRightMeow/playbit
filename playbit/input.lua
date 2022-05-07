local module = {}

!if LOVE2D then
local keyToButton = {
  up = "up",
  down = "down",
  left = "left",
  right = "right",
  s = "a",
  a = "b",
  ["`"] = "debug_stats",
  tab = "toggle_debug_stats",
  f1 = "toggle_window_size",
}

local gamepadToButton = {
  dpup = "up",
  dpdown = "down",
  dpleft = "left",
  dpright = "right",
  a = "a",
  b = "b",
}

local buttonStates = {}
for k,v in pairs(keyToButton) do
  buttonStates[v] = 0
end

local activeGamepad = nil
local isCrankDocked = false
!else
local buttonStates = {
  up = 0,
  down = 0,
  left = 0,
  right = 0,
  a = 0,
  b = 0,
}
!end

local crankDir = -1
local crankPos = 0
local lastCrankPos = 0

function module.update()
  for k,v in pairs(buttonStates) do
    if buttonStates[k] == 1 then
      buttonStates[k] = 2
    end
  end
  lastCrankPos = crankPos
end

--- Returns true when the specified button is held down.
function module.getButton(button)
  return buttonStates[button] > 0
end

--- Returns true when the specified button was pressed in the last frame.
function module.getButtonDown(button)
  return buttonStates[button] == 1
end

--- Returns true if the crank is docked.
function module.isCrankDocked()
!if LOVE2D then
  if not activeGamepad then
    -- TODO: test keyboard if no gamepad
    return isCrankDocked
  end

  -- TODO: emulate on keyboard?
  local x = math.abs(activeGamepad:getAxis(3))
  local y = math.abs(activeGamepad:getAxis(4))
  if x < 0.3 or y < 0.3 then
    return true
  end

  return false
!else
  return playdate.isCrankDocked()
!end
end

function module.getCrankChange()
!if LOVE2D then
    local change = pb.geometry.angleDiff(lastCrankPos, crankPos)
    -- TODO: how does the playdate accelerate this?
    local acceleratedChange = change 
    return change, acceleratedChange
!else
    return playdate.getCrankChange()
!end
end

--- Returns the angle the crank is currently at in radians.
function module.getCrankPosition()
!if LOVE2D then
  if not activeGamepad then
    return crankPos
  end

  local x = activeGamepad:getAxis(3)
  local y = activeGamepad:getAxis(4)

  local degrees = math.deg(math.atan2(-y, x))
  if degrees < 0 then
    return degrees + 360
  end
  return degrees
!else
  -- any reason why we'd need floating point numbers?
  return math.floor(playdate.getCrankPosition())
!end
end

function module.invertCrankRotation(enable)
  if enable then
    crankDir = -1
  else
    crankDir = 1
  end
end

!if LOVE2D then
function module.handleGamepadAdded(gamepad)
  -- always take most reset added gamepad as active gamepad
  activeGamepad = gamepad
end

function module.handleGamepadRemoved(gamepad)
  if activeGamepad == nil then
    return
  end

  if gamepad:getID() == activeGamepad:getID() then
    activeGamepad = nil
  end
end

function module.handleGamepadPressed(joystick, gamepadButton)
  local button = gamepadToButton[gamepadButton]
  if button == nil then
    return
  end

  if buttonStates[button] == nil then
    return
  end

  buttonStates[button] = 1
end

function module.handleGamepadReleased(joystick, gamepadButton)
  local button = gamepadToButton[gamepadButton]
  if button == nil then
    return
  end

  if buttonStates[button] == nil then
    return
  end

  buttonStates[button] = 0
end

function module.handleMousepressed(x, y, button, istouch, presses)
  if button ~= 3 then
    return
  end
  isCrankDocked = not isCrankDocked
  crankPos = 0
end
!end

function module.cranked(change, acceleratedChange)
  if isCrankDocked then
    return
  end

!if LOVE2D then
  -- TODO: configure scroll sensitivity?
  crankPos = crankPos + change * crankDir * 6
!elseif PLAYDATE then
  crankPos = crankPos + change * crankDir
!end
  
  if crankPos < 0 then
    crankPos = 359
  elseif crankPos > 359 then
    crankPos = 0
  end
end

function module.handleKeyPressed(key)
!if LOVE2D then
  local button = keyToButton[key]
  if button == nil then
    return
  end
!elseif PLAYDATE then
  local button = key
!end

  if buttonStates[button] == nil then
    return
  end

  buttonStates[button] = 1
end

function module.handleKeyReleased(key)
!if LOVE2D then
  local button = keyToButton[key]
  if button == nil then
    return
  end
!else
  local button = key
!end

  if buttonStates[button] == nil then
    return
  end

  buttonStates[button] = 0
end

return module