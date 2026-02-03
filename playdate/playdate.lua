local module = {}
playdate = module

require("playbit.geometry")
require("playdate.metadata")
require("playdate.sound")
require("playdate.file")
require("playdate.datastore")
require("playdate.accelerometer")
require("playdate.json")
require("playdate.pathfinder")

-- ████████╗██╗███╗   ███╗███████╗
-- ╚══██╔══╝██║████╗ ████║██╔════╝
--    ██║   ██║██╔████╔██║█████╗  
--    ██║   ██║██║╚██╔╝██║██╔══╝  
--    ██║   ██║██║ ╚═╝ ██║███████╗
--    ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝
                               
function module.getTime()
  local seconds = os.time()
  local date = os.date("*t", seconds)
  return {
    year = date.year,
    month = date.month,
    day = date.day,
    weekday = date.wday,
    hour = date.hour,
    minute = date.min,
    second = date.sec,
    -- TODO: PD also returns milliseconds to the next second, but time functions in native lua don't have millisecond precision
    millisecond = 0,
  }
end
function module.setRefreshRate(rate)
  if rate <= 0 then
    min_dt = 0 
    return
  end
  min_dt = 1/rate
end
function module.getCurrentTimeMilliseconds()
  return love.timer.getTime() * 1000
end
local elapsedStartTime = love.timer.getTime()
function module.getElapsedTime()
  return love.timer.getTime() - elapsedStartTime
end
function module.resetElapsedTime()
  elapsedStartTime = love.timer.getTime()
end
function module.getSecondsSinceEpoch()
  -- os.time() without params always returns in system local time, so we must convert to UTC
  local nowLocal = os.time()
  local nowTable = os.date("!*t", nowLocal)
  local nowUtc = os.time(nowTable)
  -- Playdate epoch, as described: https://sdk.play.date/2.6.0/Inside%20Playdate.html#f-getSecondsSinceEpoch
  local playdateEpochUtc = os.time({
    year = 2000,
    month = 1,
    day = 1,
    hour = 0,
    min = 0,
    sec = 0,
  })
  -- TODO: PD also returns milliseconds to the next second, but time functions in native lua don't have millisecond precision
  local milliseconds = 0
  return os.difftime(nowUtc, playdateEpochUtc), milliseconds
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

module._buttonToKey = {
  up = "kb_up",
  down = "kb_down",
  left = "kb_left",
  right = "kb_right",
  a = "kb_s",
  b = "kb_a",
}

module.kButtonA = "a"
module.kButtonB = "b"
module.kButtonUp = "up"
module.kButtonDown = "down"
module.kButtonLeft = "left"
module.kButtonRight = "right"

local NONE = 0
local JUST_PRESSED = 1
local PRESSED = 2
local JUST_RELEASED = 3

local inputStates = {}

function module.buttonIsPressed(button)
  local key = module._buttonToKey[button]
  if not inputStates[key] then
    -- no entry, assume no input
    return false
  end

  return inputStates[key] == JUST_PRESSED or inputStates[key] == PRESSED
end

function module.buttonJustPressed(button)
  local key = module._buttonToKey[button]
  if not inputStates[key] then
    -- no entry, assume no input
    return false
  end

  return inputStates[key] == JUST_PRESSED
end

function module.buttonJustReleased(button)
  local key = module._buttonToKey[button]
  if not inputStates[key] then
    -- no entry, assume no input
    return false
  end

  return inputStates[key] == JUST_RELEASED
end

function module.getButtonState(button)
  local key = module._buttonToKey[button]
  local value = inputStates[key]
  return value == PRESSED, value == PRESSED, value == JUST_RELEASED
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
    local change = playbit.geometry.angleDiff(lastCrankPos, crankPos)
    -- TODO: how does the playdate accelerate this?
    local acceleratedChange = change 
    return change, acceleratedChange
end

-- TODO: acceleramator, emulate via leftstick, keyboard...?

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
  -- always take most recently added joystick as active joystick
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
  inputStates["js_"..gamepadButton] = JUST_PRESSED
end

function love.gamepadreleased(joystick, gamepadButton)
  lastActiveJoystick = joystick
  inputStates["js_"..gamepadButton] = JUST_RELEASED
end

function love.mousepressed(x, y, button, istouch, presses)
  if button ~= 3 then
    return
  end

  isCrankDocked = not isCrankDocked
  crankPos = 0
  --[[ also reset lastCrankPos since on PD, you cant
  dock the crank without rotating it back to 0 --]]
  lastCrankPos = 0
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

-- emulate the keys that PD simulator supports
-- https://sdk.play.date/Inside%20Playdate.html#c-keyPressed
local supportedCallbackKeys = {
  ["1"] = true,
  ["2"] = true,
  ["3"] = true,
  ["4"] = true,
  ["5"] = true,
  ["6"] = true,
  ["7"] = true,
  ["8"] = true,
  ["9"] = true,
  ["0"] = true,
  ["q"] = true,
  ["w"] = true,
  ["e"] = true,
  ["r"] = true,
  ["t"] = true,
  ["y"] = true,
  ["u"] = true,
  ["i"] = true,
  ["o"] = true,
  ["p"] = true,
  ["a"] = true,
  ["s"] = true,
  ["d"] = true,
  ["f"] = true,
  ["g"] = true,
  ["h"] = true,
  ["j"] = true,
  ["k"] = true,
  ["l"] = true,
  ["z"] = true,
  ["x"] = true,
  ["c"] = true,
  ["v"] = true,
  ["b"] = true,
  ["n"] = true,
  ["m"] = true,
  [";"] = true,
  ["'"] = true,
  [","] = true,
  ["."] = true,
  ["/"] = true,
  ["\\"] = true,
  ["`"] = true,
}

function love.keypressed(key)
  if playdate.keyboard._visible then
    if key == 'return' or key == 'enter' then
      playdate.keyboard._closeOk()
    elseif key == 'escape' then
      playdate.keyboard._closeCancel()
    elseif key == 'backspace' or key == 'delete' then
      playdate.keyboard._backspace()
    end
    return
  elseif key == 'escape' then
    if playdate.menu.isVisible == false then
      playdate.openSystemMenu()
    else
      playdate.closeSystemMenu()
    end
  end
  inputStates["kb_"..key] = JUST_PRESSED

  --[[ Playdate only has a limited range of supported keys, so Playbit exposes the separate
  `playbit.keyPressed` handler so that it can be used to listen to any keypress under love2d. ]]--
  if playbit.keyPressed then
    playbit.keyPressed(key)
  end
  if supportedCallbackKeys[key] then
    if playdate.keyPressed then
      playdate.keyPressed(key)
    end
  end
end

function love.keyreleased(key)  
  inputStates["kb_"..key] = JUST_RELEASED

  if playbit.keyReleased then
    playbit.keyReleased(key)
  end

  if supportedCallbackKeys[key] then
    if playdate.keyReleased then
      playdate.keyReleased(key)
    end
  end
end

function module.updateInput()
  -- only update keys that are mapped
  for k,v in pairs(module._buttonToKey) do
    if inputStates[v] == JUST_PRESSED then
      inputStates[v] = PRESSED
    elseif inputStates[v] == JUST_RELEASED then
      inputStates[v] = NONE
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

function printTable(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. printTable(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
	--error("[ERR] printTable() is not yet implemented.")
end

-- debug TODO: make a fancy header
function sample()
  error("[ERR] sample() is not yet implemented.")
end

function where()
  error("[ERR] where() is not yet implemented.")
end

function module.apiVersion()
  -- TODO: return Playbit version instead?
  error("[ERR] playdate.apiVersion() is not yet implemented.")
end

module.inputHandlers = {}
module.handlerStack = {}
function module.inputHandlers.pop()
  if #module.handlerStack == 0 then
    return
  end
  local handler = table.remove(module.handlerStack)
  for key, value in pairs(handler) do
    playdate[key] = value
  end
end
function module.inputHandlers.push(handler, masksPreviousHandlers)
  local curHandler = {
    AButtonDown = playdate.AButtonDown,
    AButtonHeld = playdate.AButtonHeld,
    AButtonUp = playdate.AButtonUp,
    BButtonDown = playdate.BButtonDown,
    BButtonHeld = playdate.BButtonHeld,
    BButtonUp = playdate.BButtonUp,
    downButtonDown = playdate.downButtonDown,
    downButtonUp = playdate.downButtonUp,
    leftButtonDown = playdate.leftButtonDown,
    leftButtonUp = playdate.leftButtonUp,
    rightButtonDown = playdate.rightButtonDown,
    rightButtonUp = playdate.rightButtonUp,
    upButtonDown = playdate.upButtonDown,
    upButtonUp = playdate.upButtonUp,
    cranked = playdate.cranked
  }
  table.insert(module.handlerStack,curHandler)
  if masksPreviousHandlers then
    playdate.AButtonDown = nil
    playdate.AButtonHeld = nil
    playdate.AButtonUp = nil
    playdate.BButtonDown = nil
    playdate.BButtonHeld = nil
    playdate.BButtonUp = nil
    playdate.downButtonDown = nil
    playdate.downButtonUp = nil
    playdate.leftButtonDown = nil
    playdate.leftButtonUp = nil
    playdate.rightButtonDown = nil
    playdate.rightButtonUp = nil
    playdate.upButtonDown = nil
    playdate.upButtonUp = nil
    playdate.cranked = nil
  end
  for key, value in pairs(handler) do
    playdate[key] = value
  end
end

