
require("role.role")
require("role.role_mgr")
require("game_net.game_net")

local ItemMgr = require("item.item_mgr")
local Item = require("item.item")


MainLogic = MainLogic or class("MainLogic")

function MainLogic:ctor()
    self.role_mgr = nil
    self.item_mgr = nil
    self.game_net = nil
    self.is_first_update = true
end

function MainLogic:init()
    self.role_mgr = RoleMgr:new()
    self.role_mgr:add_role(Role:new())

    self.item_mgr = ItemMgr:new()
    self.item_mgr:add_item(Item:new())

    self.game_net = GameNet:new(
            Functional.make_closure(MainLogic.on_game_net_open, self),
            Functional.make_closure(MainLogic.on_game_net_close, self),
            Functional.make_closure(MainLogic.on_game_net_recv_msg, self)
    )
end

function MainLogic:on_frame()
    if self.is_first_update then
        self.is_first_update = false
        self.game_net:connect("127.0.0.1", 31000)
    end
    self.role_mgr:tick_role()
    self.item_mgr:tick_item()
end

function MainLogic:on_game_net_open(is_succ)

end

function MainLogic:on_game_net_close(error_num, error_msg)

end

function MainLogic:on_game_net_recv_msg(proto_id, bytes, data_begin, data_len)

end

print("reach MainLogic")