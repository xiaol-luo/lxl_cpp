
---@class GameRoleModule
GameRoleModule = GameRoleModule or class("GameRoleModule")

function GameRoleModule:ctor(role, module_name)
    ---@type GameRole
    self._role = role
    self._module_name = module_name
end

function GameRoleModule:init()
    self:_on_init()
end

function GameRoleModule:_on_init()

end

function GameRoleModule:_on_init_from_db(db_ret)
    return true
end

function GameRoleModule:_on_pack_for_db(out_ret)
    --[[ example
        info = {}
        -- ...
        if out_ret then
            out_ret.xxx = info
        end
        ]]
end

function GameRoleModule:init_from_db(db_ret)
    return self:_on_init_from_db(db_ret)
end

function GameRoleModule:pack_for_db(out_ret)
    self:_on_pack_for_db(out_ret)
end

function GameRoleModule:set_dirty()
    self._role:set_module_dirty(self._module_name)
end

function GameRoleModule:get_module_name()
    return self._module_name
end