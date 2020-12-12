
---@class Match_Room_State
Match_Room_State = {}
Match_Room_State.free = "free"
Match_Room_State.ask_teammate_accept_match = "ask_teammate_accept_match"
Match_Room_State.wait_enter_match_pool = "wait_enter_match_pool"
Match_Room_State.matching = "matching"
Match_Room_State.match_succ = "match_succ"
Match_Room_State.all_over = "all_over" -- 结束了

---@class MatchRoom
---@field unique_key string
---@field state Match_Room_State
---@field room_server_key string
---@field match_game MatchGameBase
---@field timeout_timestamp number
---@field role_replys table<number, Reply_State>
MatchRoom = MatchRoom or class("MatchRoom")

function MatchRoom:ctor()
    self.unique_key = nil
    self.state = Match_Room_State.free
    self.room_server_key = nil
    self.match_game = nil
    self.timeout_timestamp = nil
    self.role_replys = {}
end

