-- docs: https://sdk.play.date/2.6.2/Inside%20Playdate.html#pdxinfo

playdate.metadata = {}

if love.filesystem.getInfo("pdxinfo") then
  local pdxinfo = love.filesystem.newFile("pdxinfo")
  pdxinfo:open("r")
  for line in pdxinfo:lines() do
    local index = line:find("=")
    local key = line:sub(1, index - 1)
    local value = line:sub(index + 1)
    playdate.metadata[key] = value
  end
end