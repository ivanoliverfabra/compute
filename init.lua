local r = require("cc.require")
local env = setmetatable({}, {
  __index = _ENV
})
env.require, env.package = r.make(env, "/compute")

local compute = {}

compute.thread = env.require("apis.thread")
compute.event = env.require("apis.event")
compute.File = env.require("apis.file")
compute.logger = env.require("apis.logger")
compute.lod = env.require("apis.lod") -- Zod Remake

compute.utils = {}

compute.utils.String = env.require("utils.string")
compute.utils.Number = env.require("utils.number")
compute.utils.Boolean = env.require("utils.boolean")
compute.utils.Table = env.require("utils.table")

return compute
