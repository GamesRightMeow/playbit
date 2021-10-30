local components = require("playbit.components")
local util = require("playbit.util")

local System = {}

System.name = "particle-system"
System.components = { components.ParticleSystem.name }

function System.update(scene, entities)
  for i = 1, #entities, 1 do
    local entityId = entities[i]
    local particleSystem = scene:getComponent(entityId, "particle-system")
    
    if particleSystem.system then
      particleSystem.system:setParticleLifetime(particleSystem.lifetimeMin, particleSystem.lifetimeMax)
      particleSystem.system:setEmissionRate(particleSystem.emissionRate)
      particleSystem.system:setSpeed(particleSystem.speedMin, particleSystem.speedMax)
      particleSystem.system:setDirection(particleSystem.emissionDirection)

      local transform = scene:getComponent(entityId, "transform")
      local graphic = scene:getComponent(entityId, "graphic")
      local x = transform.x + graphic.x
      local y = transform.y + graphic.y
      particleSystem.system:moveTo(x, y)
      particleSystem.system:update(util.deltaTime())
    end
  end
end

return System