
Role = Role or class("Role")

Role_State =
{
    inited = 0,
    launch = 1,
    using = 2,
    idle = 3,
    released = 4,
}

function Role:ctor()
    self.state = Role_State.free
    self.role_id = nil
    self.session_id = nil
    self.gate_client = nil
    self.client_netid = nil
    self.game_client = nil
    self.cached_launch_rsp = nil -- 主要是为了处理launch过程中被顶号
end



