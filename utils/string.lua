local String = {}

function String.trim(str)
  return str:match("^%s*(.-)%s*$")
end

function String.split(str, delimiter)
  local result = {}
  for part in str:gmatch("[^" .. delimiter .. "]+") do table.insert(result, part) end
  return result
end

function String.startsWith(str, prefix)
  return str:sub(1, #prefix) == prefix
end

function String.endsWith(str, suffix)
  return str:sub(-#suffix) == suffix
end

return String
