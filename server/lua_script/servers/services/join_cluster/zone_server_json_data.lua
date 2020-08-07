
---@class ZoneServerJsonDataField
---@field cluster_server_id string
---@field db_path string
---@field zone string
---@field server_role string
---@field server_name string
---@field advertise_client_ip string
---@field advertise_client_port string
---@field advertise_peer_ip string
---@field advertise_peer_port string
ZoneServerJsonDataField = {}
ZoneServerJsonDataField.cluster_server_id = "cluster_server_id"
ZoneServerJsonDataField.db_path = "db_path"
ZoneServerJsonDataField.zone = "zone"
ZoneServerJsonDataField.server_role = "server_role"
ZoneServerJsonDataField.server_name = "server_name"
ZoneServerJsonDataField.advertise_client_ip = "advertise_client_ip"
ZoneServerJsonDataField.advertise_client_port = "advertise_client_port"
ZoneServerJsonDataField.advertise_peer_ip = "advertise_peer_ip"
ZoneServerJsonDataField.advertise_peer_port = "advertise_peer_port"

---@class ZoneServerJsonData: JsonData
---@field cluster_server_id string
---@field db_path string
---@field zone string
---@field server_role string
---@field server_name string
---@field advertise_client_ip string
---@field advertise_client_port string
---@field advertise_peer_ip string
---@field advertise_peer_port string
ZoneServerJsonData = ZoneServerJsonData or class("ZoneServerJsonData", JsonData)

function ZoneServerJsonData:ctor()
    ZoneServerJsonData.super.ctor(self, ZoneServerJsonDataField)
end
