local Number = {}

function Number.clamp(value, min, max)
  return math.min(math.max(value, min), max)
end

function Number.lerp(a, b, t)
  return a + (b - a) * t
end

function Number.randomRange(min, max, isInt)
  if isInt then return math.random(min, max) end
  return math.random() * (max - min) + min
end

function Number.isEven(n)
  return n % 2 == 0
end

function Number.isOdd(n)
  return n % 2 ~= 0
end

return Number
