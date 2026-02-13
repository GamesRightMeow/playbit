-- conf.lua
if love._os == "Windows" then
  local ffi = require "ffi"
  ffi.cdef[[ bool SetProcessDPIAware(); ]]
  ffi.C.SetProcessDPIAware();
end

function love.conf(t)
    -- TODO: only enable in debug mode
    t.console = true
    t.window.width = 400
    t.window.height = 240
    t.window.msaa = false
    t.window.usedpiscale = false
end