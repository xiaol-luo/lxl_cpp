
ServiceModuleDef = ServiceModuleDef or {}

ServiceModuleState = ServiceModuleState or {}
ServiceModuleState.Free = 0
ServiceModuleState.Inited = 1
ServiceModuleState.Starting = 2
ServiceModuleState.Started = 3
ServiceModuleState.Update = 4
ServiceModuleState.Stopping = 5
ServiceModuleState.Stopped = 6
ServiceModuleState.Released = 7

Service_Module_Event_State_Starting = "Service_Module_Event_State_Starting"
Service_Module_Event_State_Started = "Service_Module_Event_State_Started"
Service_Module_Event_State_To_Update = "Service_Module_Event_State_To_Update"
Service_Module_Event_State_Stopping = "Service_Module_Event_State_Stopping"
Service_Module_Event_State_Stopped = "Service_Module_Event_State_Stopped"
Service_Module_Event_State_Released = "Service_Module_Event_State_Released"