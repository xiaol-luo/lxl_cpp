
---@class Error.fight
Error.fight = {}
Error.fight.no_avaliable_match_server = 10


---@class Error.join_match
Error.join_match = {}
Error.join_match.already_matching = 1
Error.join_match.role_not_in_game_server = 2
Error.join_match.no_available_match_server = 3
Error.join_match.match_key_clash = 4

---@class Error.quit_match
Error.quit_match = {}
Error.quit_match.match_key_not_same = 1
Error.quit_match.can_not_quit_when_match_succ = 2

---@class Error.setup_room
---@field no_fit_theme number
---@field room_key_clash number
Error.setup_room = {}
Error.setup_room.no_fit_theme = 1
Error.setup_room.room_key_clash = 2

---@class Error.query_room_state
---@field not_find_room number
Error.query_room_state {}
Error.query_room_state.not_find_room = 1


---@class Error.notify_fight_over
---@field not_find_room number
Error.notify_fight_over {}
Error.notify_fight_over.not_find_room = 1




