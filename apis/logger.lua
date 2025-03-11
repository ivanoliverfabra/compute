local Logger = {}

local function baseLog(level, ...)
  local message = ""
  for i, v in ipairs({...}) do message = message .. tostring(v) end
  print("[" .. level:upper() .. "] " .. message)
end

function Logger.info(...)
  baseLog("info", ...)
end

function Logger.warn(...)
  baseLog("warn", ...)
end

function Logger.error(...)
  baseLog("error", ...)
end

function Logger.debug(...)
  baseLog("debug", ...)
end

return Logger
