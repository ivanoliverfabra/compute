local File = {}
File.__index = File

function File.new(path, mode)
  mode = mode or "r"
  local self = setmetatable({}, File)
  self.path = path
  self.mode = mode
  return self
end

function File:write(content)
  local file = fs.open(self.path, "w")
  if not file then return false, "Failed to open file for writing" end
  file.write(content)
  file.close()
  return self
end

function File:read()
  if not fs.exists(self.path) then
    local success, err = self:write("")
    if not success then return nil, err end
  end
  local file = fs.open(self.path, "r")
  if not file then return nil, "Failed to open file for reading" end
  local content = file.readAll()
  file.close()
  return content
end

function File:append(content)
  if not fs.exists(self.path) then
    local success, err = self:write("")
    if not success then return false, err end
  end
  local file = fs.open(self.path, "a")
  if not file then return false, "Failed to open file for appending" end
  file.write(content)
  file.close()
  return self
end

function File:delete()
  if not fs.exists(self.path) then return false, "File does not exist" end
  return fs.delete(self.path)
end

function File:exists()
  return fs.exists(self.path)
end

function File:size()
  if not fs.exists(self.path) then return nil, "File does not exist" end
  return fs.getSize(self.path)
end

return File
