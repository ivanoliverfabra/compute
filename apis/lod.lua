local Lod = {}

local Schema = {}
Schema.__index = Schema

function Schema:new(type, validator, errorMessage, fields, defaultValue)
  local self = setmetatable({}, Schema)
  self.type = type
  self.validator = validator
  self.errorMessage = errorMessage or "Validation failed"
  self.fields = fields
  self.defaultValue = defaultValue
  return self
end

function Schema:parse(data)
  local result = self:safeParse(data)
  if not result.success then error(table.concat(result.errors, "\n")) end
  return result.data
end

function Schema:safeParse(data)
  local errors = {}

  if self.type == "object" and type(data) == "table" then
    for key, fieldSchema in pairs(self.fields) do
      if data[key] == nil and fieldSchema.defaultValue then data[key] = fieldSchema.defaultValue end
    end
  else
    if data == nil and self.defaultValue then data = self.defaultValue end
  end

  local success, err = self.validator(data, errors)
  if not success then
    return {
      success = false,
      errors = errors
    }
  end
  return {
    success = true,
    data = data
  }
end

local function chainValidator(baseValidator, newValidator)
  return function(data, errors)
    if not baseValidator(data, errors) then return false end
    return newValidator(data, errors)
  end
end

local function isString(data)
  return type(data) == "string"
end

local function isNumber(data)
  return type(data) == "number"
end

local function validateType(data, errors, expectedType)
  if type(data) ~= expectedType then
    table.insert(errors, "Expected " .. expectedType .. ", got " .. type(data))
    return false
  end
  return true
end

local function validatePositive(data, errors)
  if not validateType(data, errors, "number") then return false end
  if data <= 0 then
    table.insert(errors, "Expected positive number, got " .. data)
    return false
  end
  return true
end

local function validateNegative(data, errors)
  if not validateType(data, errors, "number") then return false end
  if data >= 0 then
    table.insert(errors, "Expected negative number, got " .. data)
    return false
  end
  return true
end

local function validateInteger(data, errors)
  if not validateType(data, errors, "number") then return false end
  if data % 1 ~= 0 then
    table.insert(errors, "Expected integer, got " .. data)
    return false
  end
  return true
end

local function validateMinNumber(data, errors, minValue)
  if data < minValue then
    table.insert(errors, "Expected number >= " .. minValue .. ", got " .. data)
    return false
  end
  return true
end

local function validateMaxNumber(data, errors, maxValue)
  if data > maxValue then
    table.insert(errors, "Expected number <= " .. maxValue .. ", got " .. data)
    return false
  end
  return true
end

local function validateMinString(data, errors, minLength)
  if #data < minLength then
    table.insert(errors, "Expected string length >= " .. minLength .. ", got " .. #data)
    return false
  end
  return true
end

local function validateMaxString(data, errors, maxLength)
  if #data > maxLength then
    table.insert(errors, "Expected string length <= " .. maxLength .. ", got " .. #data)
    return false
  end
  return true
end

local function validateEmail(data, errors)
  if not data:match("[^@]+@[^@]+%.[^@]+") then
    table.insert(errors, "Expected email, got " .. data)
    return false
  end
  return true
end

local function validateEnum(data, errors, enumValues)
  for _, value in ipairs(enumValues) do if data == value then return true end end
  table.insert(errors, "Expected one of " .. table.concat(enumValues, ", ") .. ", got " .. data)
  return false
end

local function validateUUID(data, errors)
  if not data:match("^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") then
    table.insert(errors, "Expected UUID, got " .. data)
    return false
  end
  return true
end

local function validateIPAddress(data, errors)
  if not data:match("^%d+%.%d+%.%d+%.%d+$") then
    table.insert(errors, "Expected IP address, got " .. data)
    return false
  end
  return true
end

local function validateDomain(data, errors)
  if not data:match("^[%w-]+%.[%w-]+$") then
    table.insert(errors, "Expected domain, got " .. data)
    return false
  end
  return true
end

function Schema:pos()
  if self.type ~= "number" then error("Cannot call 'pos' on non-number schema") end

  return Schema:new(self.type, chainValidator(self.validator, validatePositive), "Expected positive number")
end

function Schema:neg()
  if self.type ~= "number" then error("Cannot call 'neg' on non-number schema") end

  return Schema:new(self.type, chainValidator(self.validator, validateNegative), "Expected negative number")
end

function Schema:int()
  if self.type ~= "number" then error("Cannot call 'int' on non-number schema") end

  return Schema:new(self.type, chainValidator(self.validator, validateInteger), "Expected integer")
end

function Schema:min(minValue)
  if self.type ~= "number" and self.type ~= "string" then error("Cannot call 'min' on non-number or non-string schema") end

  return Schema:new(self.type, chainValidator(self.validator, function(data, errors)
    if isNumber(data) then
      return validateMinNumber(data, errors, minValue)
    elseif isString(data) then
      return validateMinString(data, errors, minValue)
    else
      table.insert(errors, "Expected number or string, got " .. type(data))
      return false
    end
  end), "Expected number or string >= " .. minValue)
end

function Schema:max(maxValue)
  if self.type ~= "number" and self.type ~= "string" then error("Cannot call 'max' on non-number or non-string schema") end

  return Schema:new(self.type, chainValidator(self.validator, function(data, errors)
    if isNumber(data) then
      return validateMaxNumber(data, errors, maxValue)
    elseif isString(data) then
      return validateMaxString(data, errors, maxValue)
    else
      table.insert(errors, "Expected number or string, got " .. type(data))
      return false
    end
  end), "Expected number or string <= " .. maxValue)
end

function Schema:email()
  if self.type ~= "string" then error("Cannot call 'email' on non-string schema") end
  return Schema:new(self.type, chainValidator(self.validator, function(data, errors)
    if not validateType(data, errors, "string") then return false end
    return validateEmail(data, errors)
  end), "Expected email")
end

function Schema:minLength(minLength)
  if self.type ~= "string" then error("Cannot call 'minLength' on non-string schema") end

  return Schema:new(self.type, chainValidator(self.validator, function(data, errors)
    if not validateType(data, errors, "string") then return false end
    return validateMinString(data, errors, minLength)
  end), "Expected string length >= " .. minLength)
end

function Schema:maxLength(maxLength)
  if self.type ~= "string" then error("Cannot call 'maxLength' on non-string schema") end

  return Schema:new(self.type, chainValidator(self.validator, function(data, errors)
    if not validateType(data, errors, "string") then return false end
    return validateMaxString(data, errors, maxLength)
  end), "Expected string length <= " .. maxLength)
end

function Schema:default(defaultValue)
  return Schema:new(self.type, function(data, errors)
    if data == nil then
      self.defaultValue = defaultValue
      data = defaultValue
    elseif self.type == "object" and type(data) == "table" then
      for key, fieldSchema in pairs(self.fields) do
        if data[key] == nil and fieldSchema.defaultValue then data[key] = fieldSchema.defaultValue end
      end
    end
    return self.validator(data, errors)
  end, self.errorMessage, self.fields, defaultValue)
end

function Schema:message(message)
  return Schema:new(self.type, self.validator, message)
end

function Schema:enum(enumValues)
  return Schema:new(self.type, chainValidator(self.validator, function(data, errors)
    return validateEnum(data, errors, enumValues)
  end), "Expected one of " .. table.concat(enumValues, ", "))
end

function Schema:custom(validator, errorMessage)
  return Schema:new(self.type, chainValidator(self.validator, function(data, errors)
    local success, err = validator(data)
    if not success then
      table.insert(errors, errorMessage or err)
      return false
    end
    return true
  end), errorMessage)
end

function Schema:transform(transformer)
  return Schema:new(self.type, function(data, errors)
    local success, err = self.validator(data, errors)
    if not success then return false end
    return true, transformer(data)
  end, self.errorMessage)
end

function Schema:isTrue()
  if self.type ~= "boolean" then error("Cannot call 'isTrue' on non-boolean schema") end
  return Schema:new(self.type, chainValidator(self.validator, function(data, errors)
    if data ~= true then
      table.insert(errors, "Expected true, got " .. tostring(data))
      return false
    end
    return true
  end), "Expected true")
end

function Schema:isFalse()
  if self.type ~= "boolean" then error("Cannot call 'isFalse' on non-boolean schema") end
  return Schema:new(self.type, chainValidator(self.validator, function(data, errors)
    if data ~= false then
      table.insert(errors, "Expected false, got " .. tostring(data))
      return false
    end
    return true
  end), "Expected false")
end

function Schema:unique()
  if self.type ~= "array" then error("Cannot call 'unique' on non-array schema") end
  return Schema:new(self.type, chainValidator(self.validator, function(data, errors)
    local seen = {}
    for _, item in ipairs(data) do
      if seen[item] then
        table.insert(errors, "Expected unique elements, got duplicate " .. item)
        return false
      end
      seen[item] = true
    end
    return true
  end), "Expected unique elements")
end

function Schema:uuid()
  if self.type ~= "string" then error("Cannot call 'uuid' on non-string schema") end
  return Schema:new(self.type, chainValidator(self.validator, validateUUID), "Expected UUID", self.fields,
      self.defaultValue)
end

function Schema:ipAddress()
  if self.type ~= "string" then error("Cannot call 'ipAddress' on non-string schema") end
  return Schema:new(self.type, chainValidator(self.validator, validateIPAddress), "Expected IP address", self.fields,
      self.defaultValue)
end

function Schema:domain()
  if self.type ~= "string" then error("Cannot call 'domain' on non-string schema") end
  return Schema:new(self.type, chainValidator(self.validator, validateDomain), "Expected domain", self.fields,
      self.defaultValue)
end

function Schema:and_(otherSchema)
  return Schema:new(self.type, chainValidator(self.validator, function(data, errors)
    return self.validator(data, errors) and otherSchema.validator(data, errors)
  end), self.errorMessage .. " and " .. otherSchema.errorMessage, self.fields, self.defaultValue)
end

function Schema:or_(otherSchema)
  return Schema:new(self.type, chainValidator(self.validator, function(data, errors)
    return self.validator(data, errors) or otherSchema.validator(data, errors)
  end), self.errorMessage .. " or " .. otherSchema.errorMessage, self.fields, self.defaultValue)
end

function Lod.number(errorMessage)
  local baseValidator = function(data, errors)
    if type(data) ~= "number" then
      table.insert(errors, errorMessage or "Expected number, got " .. type(data))
      return false
    end
    return true
  end

  return Schema:new("number", baseValidator, errorMessage, self.fields, self.defaultValue)
end

function Lod.string(errorMessage)
  local baseValidator = function(data, errors)
    if type(data) ~= "string" then
      table.insert(errors, errorMessage or "Expected string, got " .. type(data))
      return false
    end
    return true
  end

  local schema = Schema:new("string", baseValidator, errorMessage, self.fields, self.defaultValue)

  schema.minLength = Schema.minLength
  schema.maxLength = Schema.maxLength

  return schema
end

function Lod.boolean(errorMessage)
  return Schema:new("boolean", function(data, errors)
    if type(data) ~= "boolean" then
      table.insert(errors, errorMessage or "Expected boolean, got " .. type(data))
      return false
    end
    return true
  end, errorMessage, self.fields, self.defaultValue)
end

function Lod.object(schema, errorMessage)
  local fields = {}
  for key, validator in pairs(schema) do fields[key] = validator end

  return Schema:new("object", function(data, errors)
    if type(data) ~= "table" then
      table.insert(errors, errorMessage or "Expected table, got " .. type(data))
      return false
    end
    local valid = true
    for key, validator in pairs(fields) do
      local result = validator:safeParse(data[key])
      if not result.success then
        for _, err in ipairs(result.errors) do table.insert(errors, "Field '" .. key .. "': " .. err) end
        valid = false
      end
    end
    return valid
  end, errorMessage, fields, self.defaultValue)
end

function Lod.array(elementSchema, errorMessage)
  return Schema:new("array", function(data, errors)
    if type(data) ~= "table" or #data == 0 then
      table.insert(errors, errorMessage or "Expected array, got " .. type(data))
      return false
    end
    local valid = true
    for i, item in ipairs(data) do
      local result = elementSchema:safeParse(item)
      if not result.success then
        for _, err in ipairs(result.errors) do table.insert(errors, "Element " .. i .. ": " .. err) end
        valid = false
      end
    end
    return valid
  end, errorMessage, self.fields, self.defaultValue)
end

function Lod.optional(schema, errorMessage)
  return Schema:new(schema.type, function(data, errors)
    if data == nil then return true end
    return schema:parse(data, errors)
  end, errorMessage, self.fields, self.defaultValue)
end

return Lod
