local module = {}
playdate.math = module

function module.lerp(min, max, t)
  return min + t * (max - min)
end