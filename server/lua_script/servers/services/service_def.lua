---@class Service_State
Service_State = {}
Service_State.Free = 0
Service_State.Inited = 1
Service_State.Starting = 2
Service_State.Started = 3
Service_State.Update = 4
Service_State.Stopping = 5
Service_State.Stopped = 6
Service_State.Released = 7

---@class Service_Event
Service_Event = {}
Service_Event.State_String = "Service_Event.State_String"
Service_Event.State_Starting = "Service_Event.State_Starting"
Service_Event.State_Started = "Service_Event.State_Started"
Service_Event.State_To_Update = "Service_Event.State_To_Update"
Service_Event.State_Stopping = "Service_Event.State_Stopping"
Service_Event.State_Stopped = "Service_Event.State_Stopped"
Service_Event.State_Released = "Service_Event.State_Released"

---@class
Service_Name = {}
Service_Name.hotfix = "hotfix"
Service_Name.discovery = "discovery"
Service_Name.peer_net = "peer_net"
Service_Name.rpc = "rpc"
