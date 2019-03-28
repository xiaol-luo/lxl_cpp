
EtcdConst = EtcdConst or {}
EtcdConst.Value = "value"
EtcdConst.Key = "key"
EtcdConst.Ttl = "ttl"
EtcdConst.Dir = "dir"
EtcdConst.ModifiedIndex = "modifyIndex"
EtcdConst.CreatedIndex = "createdIndex"
EtcdConst.Action = "action"
EtcdConst.Node = "node"
EtcdConst.Nodes = "nodes"
EtcdConst.PrevNode = "prevNode"
EtcdConst.Wait = "wait"
EtcdConst.Recursive = "recursive"
EtcdConst.WaitIndex = "waitIndex"
EtcdConst.Refresh = "refresh"
EtcdConst.PrevExist = "prevExist"
EtcdConst.PrevValue = "prevValue"
EtcdConst.PrevIndex = "prevIndex"
EtcdConst.ErrorCode = "errorCode"
EtcdConst.Message = "message"
EtcdConst.Cause = "cause"
EtcdConst.Index = "index"
EtcdConst.Head_Cluster_Id = "X-Etcd-Cluster-Id"
EtcdConst.Head_Index = "X-Etcd-Index"
EtcdConst.Head_Raft_Index = "X-Raft-Index"
EtcdConst.Head_Raft_Term = "X-Raft-Term"
EtcdConst.Expiration = "expiration"
EtcdConst.Rsp_State = "rsp_state"
EtcdConst.Rsp_State_OK = "OK"
EtcdConst.Rsp_State_Created = "Created"
EtcdConst.Set = "set"
EtcdConst.Delete = "delete"

EtcdEvent = EtcdEvent or {}
EtcdEvent.HttpConnect = 0
EtcdEvent.HttpClose = 1
EtcdEvent.HttpParse = 2
EtcdEvent.DnsQuery = 103

EtcdEventName = EtcdEvent or {}
EtcdEventName[EtcdEvent.HttpConnect] = "EtcdEvent.HttpConnect"
EtcdEventName[EtcdEvent.HttpClose] = "HttpConnect.HttpClose"
EtcdEventName[EtcdEvent.HttpParse] = "EtcdEvent.HttpParse"
EtcdEventName[EtcdEvent.DnsQuery] = "EtcdEvent.DnsQuery"
