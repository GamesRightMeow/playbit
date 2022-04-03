local module = {}

--! if LOVE2d then
local keyToButton = {
  up = "up",
  down = "down",
  left = "left",
  right = "right",
  z = "a",
  x = "b",
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
--! else
local buttonStates = {
  up = 0,
  down = 0,
  left = 0,
  right = 0,
  a = 0,
  b = 0,
}
--! end

function module.update()
  for k,v in pairs(buttonStates) do
    if buttonStates[k] == 1 then
      buttonStates[k] = 2
    end
  end
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
  --! if LOVE2D then
  if not activeGamepad then
    -- TODO: test keyboard if no gamepad
    return true
  end

  -- TODO: emulate on keyboard?
  local x = math.abs(activeGamepad:getAxis(3))
  local y = math.abs(activeGamepad:getAxis(4))
  if x < 0.3 or y < 0.3 then
    return true
  end

  return false
  --! else
  return playdate.isCrankDocked()
  --! end
end

--- Returns the angle the crank is currently at in radians.
function module.getCrankPosition()
  --! if LOVE2D then
  if not activeGamepad then
    -- TODO: test keyboard if no gamepad
    return 0
  end

  -- TODO: emulate on keyboard?
  local x = activeGamepad:getAxis(3)
  local y = activeGamepad:getAxis(4)

  ---@diagnostic disable-next-line: deprecated
  local degrees = math.deg(math.atan2(-y, x))
  if degrees < 0 then
    return degrees + 360
  end
  return degrees
  --! else
  return playdate.getCrankPosition()
  --! end
end

--! if LOVE2d then
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
--! end

function module.handleKeyPressed(key)
  --! if LOVE2d then
  local button = keyToButton[key]
  if button == nil then
    return
  end
  --! else
  local button = key
  --! end

  if buttonStates[button] == nil then
    return
  end

  buttonStates[button] = 1
end

function module.handleKeyReleased(key)
  --! if LOVE2d then
  local button = keyToButton[key]
  if button == nil then
    return
  end
  --! else
  local button = key
  --! end

  if buttonStates[button] == nil then
    return
  end

  buttonStates[button] = 0
end

return module