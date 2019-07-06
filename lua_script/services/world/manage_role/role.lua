
Role = Role or class("Role")

Role_State =
{
    inited = 0,
    launch = 1,
    using = 2,
    idle = 3,
    releasing = 4,
    released = 5,
}

Idle_Role_Hold_Max_Sec = 60
Role_Release_Cmd_Expire_Sec = 10
Role_Release_Try_Max_Times = 3

function Role:ctor()
    self.state = Role_State.free
    self.role_id = nil
    self.session_id = nil
    self.gate_client = nil
    self.client_netid = nil
    self.game_client = nil
    self.cached_launch_rsp = nil -- 主要是为了处理launch过程中被顶号
    self.idle_begin_sec = nil
    self.release_begin_sec = nil
    self.release_try_times = nil
    self.release_opera_ids = nil
    self.token = nil
end



