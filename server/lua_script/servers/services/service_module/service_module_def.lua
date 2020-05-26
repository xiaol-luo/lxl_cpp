
ServiceModuleDef = ServiceModuleDef or {}

Service_State = Service_State or {}
Service_State.Free = 0
Service_State.Inited = 1
Service_State.Starting = 2
Service_State.Started = 3
Service_State.Update = 4
Service_State.Stopping = 5
Service_State.Stopped = 6
Service_State.Released = 7

Service_Module_Event_State_Starting = "Service_Module_Event_State_Starting"
Service_Module_Event_State_Started = "Service_Module_Event_State_Started"
Service_Module_Event_State_To_Update = "Service_Module_Event_State_To_Update"
Service_Module_Event_State_Stopping = "Service_Module_Event_State_Stopping"
Service_Module_Event_State_Stopped = "Service_Module_Event_State_Stopped"
Service_Module_Event_State_Released = "Service_Module_Event_State_Released"