
---@class Game_Match_Item_State
Game_Match_Item_State = {}
Game_Match_Item_State.idle = "idle"
Game_Match_Item_State.wait_join_confirm = "wait_join_confirm"
Game_Match_Item_State.accepted_join = "accepted_join"
Game_Match_Item_State.matching = "matching"
Game_Match_Item_State.wait_enter_room_confirm = "wait_enter_room_confirm"
Game_Match_Item_State.accepted_enter_room = "wait_enter_room"
Game_Match_Item_State.over = "over"

---@class GameMatchItem
---@field role_id number
---@field state Game_Match_Item_State
---@field match_server_key string
---@field match_key string
---@field match_theme string
---@field leader_role_id number
---@field teammate_role_ids table<number, number>
GameMatchItem = GameMatchItem or class("GameMatchItem")

function GameMatchItem:ctor()
    self.role_id = 0
    self.state = 0
    self.match_server_key = nil
    self.match_key = nil
    self.match_theme = nil
    self.leader_role_id = 0
    self.teammate_role_ids = {}
end

