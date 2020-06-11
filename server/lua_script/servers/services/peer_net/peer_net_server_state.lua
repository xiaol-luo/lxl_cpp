
---@class PeerNetServerState
---@field server_key string
---@field server_data DiscoveryServerData
---@field cnn_unique_id number
---@field loop_cnn_unique_id number
---@field server_role_name string
---@field server_role string
---@field server_name string
PeerNetServerState = PeerNetServerState or class("PeerNetServerState")

function PeerNetServerState:ctor()
    self.server_key = nil
    self.server_data = nil
    self.cnn_unique_id = nil
    self.loop_cnn_unique_id = nil
    self.cluster_server_name = nil -- $server_role.$server_name
    self.server_role = nil
    self.server_name = nil
end

function PeerNetServerState:is_joined_cluster()
    return nil ~= self.server_data
end

function PeerNetServerState:get_cluster_server_id()
    local ret = nil
    if self.server_data then
        ret = self.server_data.data.cluster_server_id
    end
    return ret
end

function PeerNetServerState:is_none_network()
    return nil == self.cnn_unique_id
end



