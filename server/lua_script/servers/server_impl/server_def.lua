
---@class Server_Role
---@field World string
---@field Game string
Server_Role = {}
Server_Role.World = "world"
Server_Role.Game = "game"

---@class EtcdSetting
---@field name string
---@field host string
---@field user string
---@field pwd string
local EtcdSetting -- for declare