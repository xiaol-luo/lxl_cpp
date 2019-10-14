
require("role.role")
require("role.role_mgr")


local ItemMgr = require("item.item_mgr")
local Item = require("item.item")

MainLogic = MainLogic or class("MainLogic")

function MainLogic:ctor()
    self.role_mgr = nil
    self.item_mgr = nil
end

function MainLogic:init()
    self.role_mgr = RoleMgr:new()
    self.role_mgr:add_role(Role:new())

    self.item_mgr = ItemMgr:new()
    self.item_mgr:add_item(Item:new())
end

function MainLogic:on_frame()
    self.role_mgr:tick_role()
    self.item_mgr:tick_item()
end

print("reach MainLogic")