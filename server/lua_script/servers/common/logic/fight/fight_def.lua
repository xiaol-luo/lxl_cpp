

---@class Match_Theme
Match_Theme = {
    two_dice = "two_dice", -- 2人掷骰子
}

---@class Game_Match_Item_State
Game_Match_Item_State = {}
Game_Match_Item_State.idle = "idle"
Game_Match_Item_State.wait_join_confirm = "wait_join_confirm"
Game_Match_Item_State.accepted_join = "accepted_join"
Game_Match_Item_State.matching = "matching"
Game_Match_Item_State.match_succ = "match_succ"
Game_Match_Item_State.all_over = "all_over"

---@class Game_Room_Item_State
Game_Room_Item_State = {}
Game_Room_Item_State.idle = "idle"
Game_Room_Item_State.accept_enter = "accept_enter"
Game_Room_Item_State.in_room = "in_room"
Game_Room_Item_State.all_over = "all_over"

---@class Room_State
Room_State = {}
Room_State.idle = "idle"
Room_State.setup = "setup"
Room_State.ask_enter_room = "ask_enter_room"
Room_State.wait_apply_fight = "wait_start_fight"
Room_State.apply_fight = "apply_fight"
Room_State.in_fight = "in_fight"
Room_State.all_over = "all_over"


---@class Two_Dice_Opera
Two_Dice_Opera = {}
Two_Dice_Opera.roll = "roll"
Two_Dice_Opera.pull_state = "pull_state"

