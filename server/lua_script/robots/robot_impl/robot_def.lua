
---@class Robot_Role
---@field World string
---@field Game string
Robot_Role = {}
Robot_Role.World = "world"
Robot_Role.Game = "game"
Robot_Role.Gate = "gate"
Robot_Role.World_Sentinel = "world_sentinel"
Robot_Role.Create_Role = "create_role"


---@class Robot_Quit_State
---@field none
---@field quiting
---@field quited
Robot_Quit_State = {}
Robot_Quit_State.none = "Robot_Quit_State.none"
Robot_Quit_State.quiting = "Robot_Quit_State.quiting"
Robot_Quit_State.quited = "Robot_Quit_State.quited"

---@class Robot_Event
Robot_Event = {}
Robot_Event.Inited = "Robot_Event.Inited"
Robot_Event.Start = "Robot_Event.Start"
Robot_Event.Stop = "Robot_Event.Stop"
Robot_Event.Notify_Quit_Game = "Robot_Event.Notify_Quit_Game"

gen_uuid = native.gen_uuid
