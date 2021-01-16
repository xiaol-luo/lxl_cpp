
---@class Lua_App_State
Lua_App_State = {}
Lua_App_State.Free = 0
Lua_App_State.Inited = 1
Lua_App_State.Starting = 2
Lua_App_State.Started = 3
Lua_App_State.Update = 4
Lua_App_State.Stopping = 5
Lua_App_State.Stopped = 6
Lua_App_State.Released = 7

---@class Lua_App_Logic_State
Lua_App_Logic_State = {}
Lua_App_Logic_State.Free = 0
Lua_App_Logic_State.Inited = 1
Lua_App_Logic_State.Started = 2
Lua_App_Logic_State.Update = 3
Lua_App_Logic_State.Stopped = 4
Lua_App_Logic_State.Released = 5

---@class Lua_App_Logic_Name
Lua_App_Logic_Name = {}
Lua_App_Logic_Name.net_mgr = "net_mgr"
Lua_App_Logic_Name.data_mgr = "data_mgr"
Lua_App_Logic_Name.logic_mgr = "logic_mgr"

---@class Lua_App_Event
Lua_App_Event = {}
Lua_App_Event.State_String = "Lua_App_Event.State_String"
Lua_App_Event.State_Starting = "Lua_App_Event.State_Starting"
Lua_App_Event.State_Started = "Lua_App_Event.State_Started"
Lua_App_Event.State_To_Update = "Lua_App_Event.State_To_Update"
Lua_App_Event.State_Stopping = "Lua_App_Event.State_Stopping"
Lua_App_Event.State_Stopped = "Lua_App_Event.State_Stopped"
Lua_App_Event.State_Released = "Lua_App_Event.State_Released"


