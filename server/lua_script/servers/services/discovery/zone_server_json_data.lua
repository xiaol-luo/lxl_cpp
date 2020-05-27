
---@class ZoneServerJsonDataField
---@field cluster_id
---@field db_path
---@field zone
---@field server_role
---@field server_name
---@field advertise_client_ip
---@field advertise_client_port
---@field advertise_peer_ip
---@field advertise_peer_port
ZoneServerJsonDataField = {}
ZoneServerJsonDataField.cluster_id = "cluster_id"
ZoneServerJsonDataField.db_path = "db_path"
ZoneServerJsonDataField.zone = "zone"
ZoneServerJsonDataField.server_role = "server_role"
ZoneServerJsonDataField.server_name = "server_name"
ZoneServerJsonDataField.advertise_client_ip = "advertise_client_ip"
ZoneServerJsonDataField.advertise_client_port = "advertise_client_port"
ZoneServerJsonDataField.advertise_peer_ip = "advertise_peer_ip"
ZoneServerJsonDataField.advertise_peer_port = "advertise_peer_port"

---@class ZoneServerJsonData: JsonData
ZoneServerJsonData = ZoneServerJsonData or class("ZoneServerJsonData", JsonData)

function ZoneServerJsonData:ctor()
    ZoneServerJsonData.super.ctor(self, ZoneServerJsonDataField)
end
