
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


---@class Server_Quit_State
---@field none
---@field quiting
---@field quited
Server_Quit_State = {}
Server_Quit_State.none = "Server_Quit_State.none"
Server_Quit_State.quiting = "Server_Quit_State.quiting"
Server_Quit_State.quited = "Server_Quit_State.quited"

---@class Server_Event
Server_Event = {}
Server_Event.Inited = "Server_Event.Inited"
Server_Event.Start = "Server_Event.Start"
Server_Event.Stop = "Server_Event.Stop"
Server_Event.Notify_Quit_Game = "Server_Event.Notify_Quit_Game"

Server_Const = {}
Server_Const.data_dir = "data_dir"

