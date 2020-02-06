
MainRole = MainRole or class("MainRole", Role)

function MainRole:ctor(role_mgr, role_id, user_id)
    MainRole.super.ctor(self, role_mgr, role_id)
    self.user_id = user_id
end


