---@class Etcd_Const
Etcd_Const = Etcd_Const or {}
Etcd_Const.Value = "value"
Etcd_Const.Key = "key"
Etcd_Const.Ttl = "ttl"
Etcd_Const.Dir = "dir"
Etcd_Const.ModifiedIndex = "modifiedIndex"
Etcd_Const.CreatedIndex = "createdIndex"
Etcd_Const.Action = "action"
Etcd_Const.Node = "node"
Etcd_Const.Nodes = "nodes"
Etcd_Const.PrevNode = "prevNode"
Etcd_Const.Wait = "wait"
Etcd_Const.Recursive = "recursive"
Etcd_Const.WaitIndex = "waitIndex"
Etcd_Const.Refresh = "refresh"
Etcd_Const.PrevExist = "prevExist"
Etcd_Const.PrevValue = "prevValue"
Etcd_Const.PrevIndex = "prevIndex"
Etcd_Const.ErrorCode = "errorCode"
Etcd_Const.Message = "message"
Etcd_Const.Cause = "cause"
Etcd_Const.Index = "index"
Etcd_Const.Head_Cluster_Id = "X-Etcd-Cluster-Id"
Etcd_Const.Head_Index = "X-Etcd-Index"
Etcd_Const.Head_Raft_Index = "X-Raft-Index"
Etcd_Const.Head_Raft_Term = "X-Raft-Term"
Etcd_Const.Expiration = "expiration"
Etcd_Const.Rsp_State = "rsp_state"
Etcd_Const.Rsp_State_OK = "OK"
Etcd_Const.Rsp_State_Created = "Created"
Etcd_Const.Rsp_State_Unauthorized = "Unauthorized"
Etcd_Const.Set = "set"
Etcd_Const.Delete = "delete"
Etcd_Const.Expire = "expire"
Etcd_Const.Authorization = "Authorization"

---@class Etcd_Event
---@field HttpConnect number
---@field HttpClose number
---@field HttpParse number
---@field DnsQuery number
Etcd_Event = Etcd_Event or {}
Etcd_Event.HttpConnect = 0
Etcd_Event.HttpClose = 1
Etcd_Event.HttpParse = 2
Etcd_Event.DnsQuery = 103

---@class Etcd_Event_Name
Etcd_Event_Name = Etcd_Event or {}
Etcd_Event_Name[Etcd_Event.HttpConnect] = "Etcd_Event.HttpConnect"
Etcd_Event_Name[Etcd_Event.HttpClose] = "HttpConnect.HttpClose"
Etcd_Event_Name[Etcd_Event.HttpParse] = "Etcd_Event.HttpParse"
Etcd_Event_Name[Etcd_Event.DnsQuery] = "Etcd_Event.DnsQuery"
