if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
  require("lldebugger").start()
end

local pb = require("playbit.pb");
local game = pb.app.new()

function love.load()
  game:load()
end

function love.draw()
  game:draw()
end

function love.keypressed(key)
  game:keypressed(key)
end

function love.keyreleased(key)
  game:keyreleased(key)
end

function love.update()
  game:update()
end