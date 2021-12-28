local Input = {}

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

function Input.update()
  for k,v in pairs(buttonStates) do
    if buttonStates[k] == 1 then
      buttonStates[k] = 2
    end
  end
end

function Input.handeGamepadAdded(gamepad)
  -- always take most reset added gamepad as active gamepad
  activeGamepad = gamepad
end

function Input.handeGamepadRemoved(gamepad)
  if activeGamepad == nil then
    return
  end

  if gamepad:getID() == activeGamepad:getID() then
    activeGamepad = nil
  end
end

function Input.handleGamepadPressed(joystick, gamepadButton)
  local button = gamepadToButton[gamepadButton]
  if button == nil then
    return
  end

  if buttonStates[button] == nil then
    return
  end

  buttonStates[button] = 1
end

function Input.handleGamepadReleased(joystick, gamepadButton)
  local button = gamepadToButton[gamepadButton]
  if button == nil then
    return
  end

  if buttonStates[button] == nil then
    return
  end

  buttonStates[button] = 0
end

function Input.handleKeyPressed(key)
  local button = keyToButton[key]
  if button == nil then
    return
  end

  if buttonStates[button] == nil then
    return
  end

  buttonStates[button] = 1
end

function Input.handleKeyReleased(key)
  local button = keyToButton[key]
  if button == nil then
    return
  end

  if buttonStates[button] == nil then
    return
  end

  buttonStates[button] = 0
end

--- Returns true when the specified button is held down.
function Input.getButton(button)
  return buttonStates[button] > 0
end

--- Returns true when the specified button was pressed in the last frame.
function Input.getButtonDown(button)
  return buttonStates[button] == 1
end

--- Returns true if the crank is extended.
function Input.isCrankExtended()
  if not activeGamepad then
    -- TODO: test keyboard if no gamepad
    return false
  end

  -- TODO: emulate on keyboard?
  local x = math.abs(activeGamepad:getAxis(3))
  local y = math.abs(activeGamepad:getAxis(4))
  if x > 0.3 or y > 0.3 then
    return true
  end
  return false
end

--- Returns the angle the crank is currently at in radians.
function Input.getCrank()
  if not activeGamepad then
    -- TODO: test keyboard if no gamepad
    return 0
  end

  -- TODO: emulate on keyboard?
  local x = activeGamepad:getAxis(3)
  local y = activeGamepad:getAxis(4)

  ---@diagnostic disable-next-line: deprecated
  return math.atan2(-y, x)
end

--- Returns the angle the crank is currently at in degrees.
function Input.getCrankDeg()
  local degrees = math.deg(Input.getCrank())
  if degrees < 0 then
    return degrees + 360
  end
  return degrees
end

return Input