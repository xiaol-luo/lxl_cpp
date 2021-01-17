
---@class Fight_Data_Event
Fight_Data_Event = {}

Fight_Data_Event.bind_fight_state_change = "Fight_Data_Event.bind_fight_state_change"
Fight_Data_Event.rsp_fight_opera = "Fight_Data_Event.rsp_fight_opera"

---@class Bind_Fight_State
Bind_Fight_State = {}
Bind_Fight_State.ready = 0
Bind_Fight_State.idle = -1
Bind_Fight_State.binding = -2
Bind_Fight_State.connect_fail = -3
Bind_Fight_State.net_error = -4
-- 其他值就是错误码
