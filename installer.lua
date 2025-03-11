local projectName = "compute"
local githubName = "ivanoliverfabra"
local githubBranch = "main"

local projectURL = "https://raw.githubusercontent.com/" .. githubName .. "/" .. projectName .. "/" .. githubBranch

local function getFiles()
  local filesResponse = http.get(projectURL .. "/files.txt")
  if not filesResponse then return nil, "Failed to get files.txt" end

  local content = filesResponse.readAll()
  filesResponse.close()

  -- Split the content into lines and store in a table
  local files = {}
  for line in content:gmatch("[^\r\n]+") do table.insert(files, line) end

  return files
end

local function downloadFile(file)
  local response = http.get(projectURL .. file)
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

local success, err = install()
if not success then error(err) end
print("Installation successful")
