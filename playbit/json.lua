local module = {}

!if LOVE2D then
local jsonParser = pb.import("json/json")
!end

function module.decode(json)
!if LOVE2D then
  return jsonParser.decode(json)
!elseif PLAYDATE then
  return json.decode(json)
!end
end

function module.decodeFile(path)
!if LOVE2D then
  local contents, size = love.filesystem.read(path)
  return jsonParser.decode(contents)
!elseif PLAYDATE then
  return json.decodeFile(path)
!end
end

return module