local Boolean = {}

function Boolean.isTruthy(value)
  return not not value
end

function Boolean.isFalsy(value)
  return not value
end

function Boolean.invert(value)
  return not value
end

return Boolean
