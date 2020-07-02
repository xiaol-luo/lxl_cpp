
---@class CreateRoleLogicService:LogicServiceBase
CreateRoleLogicService = CreateRoleLogicService or class("LogicService", LogicServiceBase)

function CreateRoleLogicService:_on_init()
    CreateRoleLogicService.super._on_init(self)

    local create_role_logic = CreateRoleLogic:new(self, Create_Role_Logic_Name.create_role)
    create_role_logic:init()
    self:add_logic(create_role_logic)

end