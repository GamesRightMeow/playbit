local module = {}
playdate.geometry.affineTransform = module

local meta = {}
meta.__index = meta
module.__index = meta

local function concat(a, b)
  return
    a.m11 * b.m11 + a.m21 * b.m12,
    a.m12 * b.m11 + a.m22 * b.m12,
    a.m11 * b.m21 + a.m21 * b.m22,
    a.m12 * b.m21 + a.m22 * b.m22,
    a.tx  * b.m11 + a.ty  * b.m12 + b.tx,
    a.tx  * b.m21 + a.ty  * b.m22 + b.ty
end


local function transform(t, x, y)
  return
    x * t.m11 + y * t.m12 + t.tx,
    x * t.m21 + y * t.m22 + t.ty
end

local function translation(dx, dy)
  return module.new(1, 0, 0, 1, dx, dy)
end

local function scaling(sx, sy)
  sy = sy or sx
  return module.new(sx, 0, 0, sy, 0, 0)
end

local function rotation(angle)
  angle = math.rad(angle)
  local c = math.cos(angle)
  local s = math.sin(angle)
  return module.new(c, -s, s, c, 0, 0)
end

local function rotationAround(angle, px, py)
  local rad = math.rad(angle)
  local c = math.cos(rad)
  local s = math.sin(rad)
  local tx = px - px * c + py * s
  local ty = py - px * s - py * c
  return module.new(c, -s, s, c, tx, ty)
end

local function skewing(sx, sy)
  local rx = math.tan(math.rad(sx))
  local ry = math.tan(math.rad(sy))
  return module.new(1, rx, ry, 1, 0, 0)
end

function module.new(m11, m12, m21, m22, tx, ty)
  local o = {}

  o.m11 = m11 or 1
  o.m12 = m12 or 0
  o.m21 = m21 or 0
  o.m22 = m22 or 1
  o.tx  = tx  or 0
  o.ty  = ty  or 0

  setmetatable(o, meta)
  return o
end

function meta:copy()
  return module.new(self.m11, self.m12, self.m21, self.m22, self.tx, self.ty)
end

function meta:unpack()
  return self.m11, self.m12, self.m21, self.m22, self.tx, self.ty
end

function meta:invert()
  local a, b   = self.m11, self.m12
  local c, d   = self.m21, self.m22
  local tx, ty = self.tx,  self.ty

  local det = a * d - b * c
  local invDet = 1 / det

  local im11 = d * invDet
  local im12 = -b * invDet
  local im21 = -c * invDet
  local im22 = a * invDet

  local itx = -(im11 * tx + im12 * ty)
  local ity = -(im21 * tx + im22 * ty)

  self.m11 = im11
  self.m12 = im12
  self.m21 = im21
  self.m22 = im22
  self.tx  = itx
  self.ty  = ity
end

function meta:reset()
  self.m11 = 1
  self.m12 = 0
  self.m21 = 0
  self.m22 = 1
  self.tx  = 0
  self.ty  = 0
end

function meta:concat(b)
  self.m11, self.m12, self.m21, self.m22, self.tx, self.ty = concat(self, b)
end

function meta:translate(dx, dy)
  local t = translation(dx, dy)
  self:concat(t)
end

function meta:translatedBy(dx, dy)
  local t = self:copy()
  t:translate(dx, dy)
  return t
end

function meta:scale(sx, sy)
  local t = scaling(sx, sy)
  self:concat(t)
end

function meta:scaledBy(sx, sy)
  local t = self:copy()
  t:scale(sx, sy)
  return t
end

function meta:rotate(angle, x, y)
  local t

  if x then
    if y then
      t = rotationAround(angle, x, y)
    else
      local pt = x
      t = rotationAround(angle, pt.x, pt.y)
    end
  else
    t = rotation(angle)
  end

  self:concat(t)
end

function meta:rotatedBy(angle, pointOrX, y)
  local t = self:copy()
  t:rotate(angle, pointOrX, y)
  return t
end

function meta:skew(sx, sy)
  local t = skewing(sx, sy)
  self:concat(t)
end

function meta:skewedBy(sx, sy)
  local t = self:copy()
  t:skew(sx, sy)
  return t
end

function meta:transformXY(x, y)
  return transform(self, x, y)
end

function meta:transformPoint(p)
  p.x, p.y = transform(self, p.x, p.y)
end

function meta:transformedPoint(p)
  local c = p:copy()
  self:transformPoint(c)
  return c
end

function meta:transformLineSegment(ls)
  ls.x1, ls.y1 = transform(self, ls.x1, ls.y1)
  ls.x2, ls.y2 = transform(self, ls.x2, ls.y2)
end

function meta:transformedLineSegment(ls)
  local c = ls:copy()
  self:transformLineSegment(c)
  return c
end

function meta:transformAABB(r)
  error("[ERR] playdate.geometry.affineTransform:transformAABB() is not yet implemented.")
end

function meta:transformedAABB(r)
  local c = r:copy()
  self:transformAABB(c)
  return c
end

function meta:transformPolygon(p)
  local pts = p._points
  for i = 1, #pts, 2 do
    local j = i + 1
    pts[i], pts[j] = transform(self, pts[i], pts[j])
  end
  -- reset cached length
  p._length = nil
end

function meta:transformedPolygon(p)
  local c = p:copy()
  self:transformPolygon(c)
  return c
end

meta.__mul = function(a, b)
  if b._type == "point" then
    local x, y = transform(a, b.x, b.y)
    return playdate.geometry.point.new(x, y)

  elseif b._type == "vector2D" then
    local dx, dy = transform(a, b.dx, b.dy)
    return playdate.geometry.vector2D.new(dx, dy)

  else
    local m11, m12, m21, m22, tx, ty = concat(a, b)
    return module.new(m11, m12, m21, m22, tx, ty)
  end
end

meta.__tostring = function(t)
    return string.format("(m11=%s, m12=%s, m21=%s, m22=%s, tx=%s, ty=%s)",
      t.m11, t.m12, t.m21, t.m22, t.tx, t.ty)
end