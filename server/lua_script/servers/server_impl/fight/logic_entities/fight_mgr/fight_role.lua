
---@class FightRole
FightRole = FightRole or class("FightRole")

function FightRole:ctor()
    self.netid = nil
    self.role_id = nil
    self.wt = table.gen_weak_table("v")
    ---@type FightBase
    self.wt.fight = nil
    ---@type FightClient
    self.wt.client = nil
end