
---@class Match_Item_State
Match_Item_State = {}
Match_Item_State.free = "free"
Match_Item_State.ask_teammate_accept_match = "ask_teammate_accept_match"
Match_Item_State.wait_enter_match_pool = "wait_enter_match_pool"
Match_Item_State.matching = "matching"
Match_Item_State.match_done = "match_done"
Match_Item_State.over = "over" -- 结束了

---@class MatchItem
---@field match_theme string
---@field match_key string
---@field match_team MatchTeamBase
---@field state Match_Item_State
---@field match_logic MatchLogicBase
MatchItem = MatchItem or class("MatchItem")

function MatchItem:ctor()
    self.match_theme = nil
    self.match_key = nil
    self.match_team = nil
    self.state = Match_Item_State.free
    self.match_logic = nil
    self.role_replys = nil
end




