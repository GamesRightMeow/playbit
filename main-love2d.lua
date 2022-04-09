--! if DEBUG then
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end
--! end

require("playbit.pb")
pb.import("scripts/game")

function love.load()
  pb.app.load()
end

function love.update()
  pb.app.update()
end

function love.draw()
  pb.app.render()
end

function love.mousepressed(x, y, button, istouch, presses)
  pb.input.handleMousepressed(x, y, button, istouch, presses)
end

function love.wheelmoved(x, y)
  pb.input.handleMouseWheel(x, y)
end

function love.joystickadded(joystick)
  pb.input.handleJoystickAdded(joystick)
end

function love.joystickremoved(joystick)
  pb.input.handleJoystickRemoved(joystick)
end

function love.gamepadreleased(joystick, button)
  pb.input.handleGamepadReleased(joystick, button)
end

function love.gamepadpressed(joystick, button)
  pb.input.handleGamepadPressed(joystick, button)
end

function love.keypressed(key)
  pb.input.handleKeyPressed(key)
end

function love.keyreleased(key)
  pb.input.handleKeyReleased(key)
end