local module = {}
json = module

local jsonParser = require("json.json")

function module.decode(json)
  return jsonParser.decode(json)
end

function module.decodeFile(path)
  local contents, size = love.filesystem.read(path)
  return jsonParser.decode(contents)
end

