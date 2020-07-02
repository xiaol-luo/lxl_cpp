
---@class CreateRoleLogic:LogicEntity
CreateRoleLogic = CreateRoleLogic or class("CreateRoleLogic", LogicEntity)

function CreateRoleLogic:_on_init()
    CreateRoleLogic.super._on_init(self)
end

function CreateRoleLogic:_on_release()
    CreateRoleLogic.super._on_release(self)
end

function CreateRoleLogic:_on_update()
    log_print("CreateRoleLogic:_on_update")
end
