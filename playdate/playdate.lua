local module = {}
playdate = module

require("playbit.geometry")
require("playdate.metadata")
require("playdate.math")
require("playdate.sound")
require("playdate.file")
require("playdate.datastore")
require("playdate.accelerometer")
require("playdate.json")
require("playdate.geometry")

-- ████████╗██╗███╗   ███╗███████╗
-- ╚══██╔══╝██║████╗ ████║██╔════╝
--    ██║   ██║██╔████╔██║█████╗
--    ██║   ██║██║╚██╔╝██║██╔══╝
--    ██║   ██║██║ ╚═╝ ██║███████╗
--    ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝

local startTime = love.timer.getTime()

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

function module.wait(milliseconds)
  love.timer.sleep(milliseconds / 1000)
end

function module.stop()
  error("[ERR] playdate.stop() is not yet implemented.")
end

function module.start()
  error("[ERR] playdate.start() is not yet implemented.")
end

function module.restart(arg)
  error("[ERR] playdate.restart() is not yet implemented.")
end

function module.restart()
  error("[ERR] playdate.restart() is not yet implemented.")
end

function module.getSystemMenu()
  error("[ERR] playdate.getSystemMenu() is not yet implemented.")
end

function module.setMenuImage(image, xOffset)
  error("[ERR] playdate.setMenuImage() is not yet implemented.")
end

function module.getSystemLanguage()
  error("[ERR] playdate.getSystemLanguage() is not yet implemented.")
end

function module.getReduceFlashing()
  error("[ERR] playdate.getReduceFlashing() is not yet implemented.")
end

function module.getFlipped()
  error("[ERR] playdate.getFlipped() is not yet implemented.")
end

function module.startAccelerometer()
  error("[ERR] playdate.startAccelerometer() is not yet implemented.")
end

function module.stopAccelerometer()
  error("[ERR] playdate.stopAccelerometer() is not yet implemented.")
end

function module.readAccelerometer()
  error("[ERR] playdate.readAccelerometer() is not yet implemented.")
end

function module.accelerometerIsRunning()
  error("[ERR] playdate.accelerometerIsRunning() is not yet implemented.")
end

function module.setAutoLockDisabled(disable)
  error("[ERR] playdate.setAutoLockDisabled() is not yet implemented.")
end

function module.getCurrentTimeMilliseconds()
  return love.timer.getTime() * 1000
end

function module.resetElapsedTime()
  startTime = love.timer.getTime()
end

function module.getElapsedTime()
  return love.timer.getTime() - startTime
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

function module.getTime()
  error("[ERR] playdate.getTime() is not yet implemented.")
end

function module.getGMTTime()
  error("[ERR] playdate.getGMTTime() is not yet implemented.")
end

function module.epochFromTime(time)
  error("[ERR] playdate.epochFromTime() is not yet implemented.")
end

function module.epochFromGMTTime(time)
  error("[ERR] playdate.epochFromTime() is not yet implemented.")
end

function module.timeFromEpoch(seconds, milliseconds)
  error("[ERR] playdate.timeFromEpoch() is not yet implemented.")
end

function module.GMTTimeFromEpoch(seconds, milliseconds)
  error("[ERR] playdate.GMTTimeFromEpoch() is not yet implemented.")
end

function module.getServerTime(callback)
  error("[ERR] playdate.getServerTime() is not yet implemented.")
end

function module.shouldDisplay24HourTime()
  error("[ERR] playdate.shouldDisplay24HourTime() is not yet implemented.")
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
  local key = module._buttonToKey[string.lower(button)]
  if not inputStates[key] then
    -- no entry, assume no input
    return false
  end

  return inputStates[key] == JUST_PRESSED or inputStates[key] == PRESSED
end

function module.buttonJustPressed(button)
  local key = module._buttonToKey[string.lower(button)]
  if not inputStates[key] then
    -- no entry, assume no input
    return false
  end

  return inputStates[key] == JUST_PRESSED
end

function module.buttonJustReleased(button)
  local key = module._buttonToKey[string.lower(button)]
  if not inputStates[key] then
    -- no entry, assume no input
    return false
  end

  return inputStates[key] == JUST_RELEASED
end

function module.getButtonState(button)
  local key = module._buttonToKey[string.lower(button)]
  local value = inputStates[key]
  return value == PRESSED, value == PRESSED, value == JUST_RELEASED
end

function module.setButtonQueueSize(size)
  error("[ERR] playdate.setButtonQueueSize() is not yet implemented.")
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

-- TODO: emulate via leftstick, keyboard...?
-- accelerometer defined in accelerometer.lua

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

function module.getCrankTicks(ticksPerRevolution)
  error("[ERR] playdate.getCrankTicks() is not yet implemented.")
end

function module.setCrankSoundsDisabled(disable)
  error("[ERR] playdate.getCrankTicks() is not yet implemented.")
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

-- playdate itself is the default input handler
-- https://sdk.play.date/3.0.2/Inside%20Playdate.html#buttonCallbacks
local inputHandlers = { { handler = playdate } }

module.inputHandlers = { }

function module.inputHandlers.push(handler, masksPreviousHandlers)
  local entry = { handler = handler, masksPreviousHandlers = masksPreviousHandlers }
  table.insert(inputHandlers, entry)
end

function module.inputHandlers.pop()
  table.remove(inputHandlers)
end

local inputHandlersEvents = {
  [JUST_PRESSED] = {
    up = "upButtonDown",
    down = "downButtonDown",
    left = "leftButtonDown",
    right = "rightButtonDown",
    a = "AButtonDown",
    b = "BButtonDown",
  },
  [JUST_RELEASED] = {
    up = "upButtonUp",
    down = "downButtonUp",
    left = "leftButtonUp",
    right = "rightButtonUp",
    a = "AButtonUp",
    b = "BButtonUp",
  },
  [PRESSED] = {
    a = "AButtonHeld",
    b = "BButtonHeld",
  }
}

local function postInputHandlersEvent(evt)
  for i = #inputHandlers, 1, -1 do
    local entry = inputHandlers[i]
    local func = entry.handler[evt]
    if func then
      func()
      return
    elseif entry.masksPreviousHandlers then
      return
    end
  end
end

local function postInputHandlersCrankedEvent(change, acceleratedChange)
  for i = #inputHandlers, 1, -1 do
    local entry = inputHandlers[i]
    local cranked = entry.handler.cranked
    if cranked then
      cranked(change, acceleratedChange)
    end
    if entry.masksPreviousHandlers == true then
      break;
    end
  end
end

local function updateInputHandlers()
  for k,v in pairs(module._buttonToKey) do
    local state = inputStates[v]
    local events = inputHandlersEvents[state]
    if events then
      local buttonEvent = events[k]
      if buttonEvent then
        postInputHandlersEvent(buttonEvent)
      end
    end
  end

  if lastCrankPos ~= crankPos then
    local change, acceleratedChange = module.getCrankChange()
    postInputHandlersCrankedEvent(change, acceleratedChange)
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
  -- update input handlers before advancing JUST_PRESSED and JUST_RELEASED states
  updateInputHandlers();

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

function module.setNewlinePrinted(flag)
  error("[ERR] playdate.setNewlinePrinted() is not yet implemented.")
end

function module.getFPS()
  return love.timer.getFPS()
end

function module.drawFPS(x, y)
  -- not implemented yet, but do not produce errors
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

function printTable(...)
	error("[ERR] printTable() is not yet implemented.")
end

-- debug TODO: make a fancy header
function sample()
  error("[ERR] sample() is not yet implemented.")
end

function module.getStats()
  error("[ERR] playdate.getStats() is not yet implemented.")
end

function module.setStatsInterval(seconds)
  error("[ERR] playdate.setStatsInterval() is not yet implemented.")
end

function where()
  error("[ERR] where() is not yet implemented.")
end

function module.apiVersion()
  -- TODO: return Playbit version instead?
  error("[ERR] playdate.apiVersion() is not yet implemented.")
end

function module.getPowerStatus()
  error("[ERR] playdate.getPowerStatus() is not yet implemented.")
end

function module.getBatteryPercentage()
  error("[ERR] playdate.getBatteryPercentage() is not yet implemented.")
end

function module.getBatteryVoltage()
  error("[ERR] playdate.getBatteryVoltage() is not yet implemented.")
end

function module.clearConsole()
  error("[ERR] playdate.clearConsole() is not yet implemented.")
end

function module.setDebugDrawColor(r, g, b, a)
  error("[ERR] playdate.setDebugDrawColor() is not yet implemented.")
end

function module.setCollectsGarbage(flag)
  error("[ERR] playdate.setCollectsGarbage() is not yet implemented.")
end

function module.setMinimumGCTime(ms)
  error("[ERR] playdate.setMinimumGCTime() is not yet implemented.")
end

function module.setGCScaling(min, max)
  error("[ERR] playdate.setGCScaling() is not yet implemented.")
end
