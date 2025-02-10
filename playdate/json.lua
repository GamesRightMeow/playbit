-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#M-json

local module = {}
json = module

local jsonParser = require("json.json")

function module.decode(json)
  return jsonParser.decode(json)
end

-- TODO: handle overloaded signature (file) - where `file` is a playdate.file.file
function module.decodeFile(path)
  local contents, size = love.filesystem.read(path)
  return jsonParser.decode(contents)
end

function module.encode(table)
  error("[ERR] json.encode() is not yet implemented.")
end

function module.encodePretty(table)
  error("[ERR] json.encodePretty() is not yet implemented.")
end

-- TODO: handle overloaded signature (file, pretty, table) - where `file` is a playdate.file.file
function module.encodeToFile(path, pretty, table)
  error("[ERR] json.encodeToFile() is not yet implemented.")
end
