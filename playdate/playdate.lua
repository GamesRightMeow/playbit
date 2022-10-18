local module = {}
playdate = module

require("playbit.geometry")

function module.getCurrentTimeMilliseconds()
  return love.timer.getTime() * 1000
end

-- ██╗███╗   ██╗██████╗ ██╗   ██╗████████╗
-- ██║████╗  ██║██╔══██╗██║   ██║╚══██╔══╝
-- ██║██╔██╗ ██║██████╔╝██║   ██║   ██║   
-- ██║██║╚██╗██║██╔═══╝ ██║   ██║   ██║   
-- ██║██║ ╚████║██║     ╚██████╔╝   ██║   
-- ╚═╝╚═╝  ╚═══╝╚═╝      ╚═════╝    ╚═╝   
  
local lastActiveJoystick = nil
local isCrankDocked = false
local crankPos = 0
local lastCrankPos = 0

local keyToButton = {
  up = "up",
  down = "down",
  left = "left",
  right = "right",
  s = "a",
  a = "b",
}

local joystickToButton = {
  dpup = "up",
  dpdown = "down",
  dpleft = "left",
  dpright = "right",
  a = "a",
  b = "b",
}

-- 0=no input, 1=just pressed, 2=pressed, 3=just released
local buttonStates = {
  up = 0,
  down = 0,
  left = 0,
  right = 0,
  a = 0,
  b = 0,
}

function module.buttonIsPressed(button)
  return buttonStates[button] == 1 or buttonStates[button] == 2
end

function module.buttonJustPressed(button)
  return buttonStates[button] == 1
end

function module.buttonJustReleased(button)
  return buttonStates[button] == 3
end

function module.isCrankDocked()
  if not lastActiveJoystick then
    return isCrankDocked
  end

  -- TODO: is basing dock state on if stick is non-zero a bad assumption here?
  -- will other games want a dedicated dock/undock button?
  local x = math.abs(lastActiveJoystick:getAxis(3))
  local y = math.abs(lastActiveJoystick:getAxis(4))
  local len = math.sqrt(x * x + y * y)
  -- TODO: deadzone sensitivity?
  if len < 0.1 then
    return true
  end

  return false
end

function module.getCrankChange()
    local change = pb.geometry.angleDiff(lastCrankPos, crankPos)
    -- TODO: how does the playdate accelerate this?
    local acceleratedChange = change 
    return change, acceleratedChange
end

function module.getCrankPosition()
  if module.isCrankDocked() then
    return 0
  end

  if not lastActiveJoystick then
    return crankPos
  end

  local x = lastActiveJoystick:getAxis(3)
  local y = lastActiveJoystick:getAxis(4)

  local degrees = math.deg(math.atan2(-y, x))
  if degrees < 0 then
    return degrees + 360
  end
  return degrees
end

function love.joystickadded(joystick)
  -- always take most reset added joystick as active joystick
  lastActiveJoystick = joystick
end

function love.joystickremoved(joystick)
  if lastActiveJoystick == nil then
    return
  end

  if joystick:getID() == lastActiveJoystick:getID() then
    lastActiveJoystick = nil
  end
end

function love.gamepadpressed(joystick, gamepadButton)
  lastActiveJoystick = joystick

  local button = joystickToButton[gamepadButton]
  if not button then
    -- button not mapped
    return
  end

  buttonStates[button] = 1
end

function love.gamepadreleased(joystick, gamepadButton)
  lastActiveJoystick = joystick

  local button = joystickToButton[gamepadButton]
  if not button then
    -- button not mapped
    return
  end

  buttonStates[button] = 3
end

function love.mousepressed(x, y, button, istouch, presses)
  if button ~= 3 then
    return
  end

  isCrankDocked = not isCrankDocked
  crankPos = 0
end

function love.wheelmoved(x, y)
  if isCrankDocked then
    return
  end

  -- TODO: emulate PD crank acceleration?
  -- TODO: configure scroll sensitivity?
  crankPos = crankPos + -y * 6
  
  if crankPos < 0 then
    crankPos = 359
  elseif crankPos > 359 then
    crankPos = 0
  end
end

function love.keypressed(key)
  local button = keyToButton[key]
  if not button then
    -- button not mapped
    return
  end

  buttonStates[button] = 1
end

function love.keyreleased(key)
  local button = keyToButton[key]
  if not button then
    -- button not mapped
    return
  end
  
  buttonStates[button] = 3
end

function module.updateInput()
  for k,v in pairs(buttonStates) do
    if buttonStates[k] == 1 then
      buttonStates[k] = 2
    elseif buttonStates[k] == 3 then
      buttonStates[k] = 0
    end
  end
  lastCrankPos = crankPos
end

-- ██╗     ██╗   ██╗ █████╗ 
-- ██║     ██║   ██║██╔══██╗
-- ██║     ██║   ██║███████║
-- ██║     ██║   ██║██╔══██║
-- ███████╗╚██████╔╝██║  ██║
-- ╚══════╝ ╚═════╝ ╚═╝  ╚═╝
                         
function table.indexOfElement(table, element)
  for i = 1, #table do
    if table[i] == element then
      return i
    end
  end
  return nil
end