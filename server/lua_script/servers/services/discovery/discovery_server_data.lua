
---@class DiscoveryServerData
---@field key string
---@field value string
---@field create_index number
---@field modified_index number
---@field data ZoneServerJsonData
DiscoveryServerData = DiscoveryServerData or class("DiscoveryServerData")

function DiscoveryServerData:ctor()
    self.key = nil
    self.value = nil
    self.create_index = nil
    self.modified_index = nil
    self.data = nil
end

function DiscoveryService:get_cluster_server_key()
    return self.key
end

