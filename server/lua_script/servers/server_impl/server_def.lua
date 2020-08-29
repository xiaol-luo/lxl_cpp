
---@class Server_Role
---@field World string
---@field Game string
Server_Role = {}
Server_Role.Login = "login"
Server_Role.World = "world"
Server_Role.Game = "game"
Server_Role.Gate = "gate"
Server_Role.World_Sentinel = "world_sentinel"
Server_Role.Create_Role = "create_role"
Server_Role.Auth = "auth"
Server_Role.Platform = "platform"
Server_Role.Match = "match"
Server_Role.Room = "room"
Server_Role.Fight = "fight"


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
