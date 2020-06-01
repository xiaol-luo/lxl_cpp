
---@class PeerNetCnnState
---@field unique_id number
---@field cnn PidBinCnn
---@field cnn_type string
---@field server_key string
---@field server_data DiscoveryServerData
---@field is_ok boolean
---@field recv_msg_counts number
---@field error_num number
---@field cnn_async_id number
---@field cached_pid_bins table<string, table<number, string> >
PeerNetCnnState = PeerNetCnnState or class("PeerNetCnnState")

function PeerNetCnnState:ctor()
    self.unique_id = nil
    self.cnn = nil
    self.cnn_type = nil -- Peer_Net_Const.accept_cnn_type|Peer_Net_Const.peer_cnn_type
    self.server_key = nil
    self.server_id = nil
    self.server_data = nil
    self.is_ok = nil -- nil:悬而未决，true:可用, false:不可用
    self.recv_msg_counts = 0
    self.error_num = nil
    self.cnn_async_id = nil
    self.cached_pid_bins = {} -- 缓存的数据
end