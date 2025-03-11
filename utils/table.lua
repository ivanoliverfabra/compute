local Table = {}

function Table.deepCopy(tbl)
  local copy = {}
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      copy[k] = Table.deepCopy(v)
    else
      copy[k] = v
    end
  end
  return copy
end

function Table.merge(tbl1, tbl2)
  local result = Table.deepCopy(tbl1)
  for k, v in pairs(tbl2) do result[k] = v end
  return result
end

function Table.filter(tbl, condition)
  local result = {}
  for k, v in pairs(tbl) do if condition(k, v) then result[k] = v end end
  return result
end

return Table
