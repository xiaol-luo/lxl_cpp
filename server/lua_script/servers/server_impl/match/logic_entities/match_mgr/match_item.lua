
---@class Match_Item_State
Match_Item_State = {}
Match_Item_State.free = "free"
Match_Item_State.ask_teammate_accept_match = "ask_teammate_accept_match"
Match_Item_State.all_teammate_accept_match = "all_teammate_accept_match"
Match_Item_State.matching = "matching"
Match_Item_State.match_succ = "match_succ"
Match_Item_State.wait_room = "wait_enter_room"
Match_Item_State.ask_teammate_accept_enter_room = "ask_teammate_accept_enter_room"
Match_Item_State.all_teammate_accept_enter_room = "all_teammate_accept_enter_room"
Match_Item_State.enter_room = "enter_room"; -- done

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
end




