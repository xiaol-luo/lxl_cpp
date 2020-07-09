
---@class GameRole
GameRole = GameRole or class("GameRole")

function GameRole:ctor(mgr, world_server_key, user_id, role_id, session_id)
    self._mgr = mgr
    self.world_server_key = world_server_key
    self.user_id = user_id
    self.role_id = role_id
    self.session_id = session_id
    self.state = Game_Role_State.inited
end





