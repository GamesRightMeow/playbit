-- Lua 5.2+ functions missing in LuaJIT which love2d uses

table.unpack = table.unpack or unpack

table.pack = table.pack or function(...)
  return { n = select("#", ...), ... }
end
