local projectName = "compute"
local githubName = "ivanoliverfabra"
local githubBranch = "main"

local projectURL = "https://raw.githubusercontent.com/" .. githubName .. "/" .. projectName .. "/" .. githubBranch

local function getFiles()
  local files = http.get(projectURL .. "/files.txt")
  if not files then return nil, "Failed to get files" end
  local filesTable = textutils.unserialize(files.readAll())
  files.close()
  return filesTable
end

local function downloadFile(file)
  local response = http.get(projectURL .. "/" .. file)
  if not response then return false, "Failed to download file" end
  local content = response.readAll()
  response.close()
  return content
end

local function install()
  local files = getFiles()
  if not files then return false, "Failed to get files" end
  for i, file in ipairs(files) do
    local content, err = downloadFile(file)
    if not content then return false, err end
    local file = fs.open(file, "w")
    if not file then return false, "Failed to open file for writing" end
    file.write(content)
    file.close()
  end
  return true
end

print("Installing " .. projectName .. "...")
print("This may take a while")

local files = getFiles()
for i, file in ipairs(files) do print(file) end

-- local success, err = install()
-- if not success then error(err) end
-- print("Installation successful")
