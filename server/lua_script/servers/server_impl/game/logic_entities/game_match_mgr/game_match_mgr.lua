---@class GameMatchMgr:GameServerLogicEntity
---@field logics GameLogicService
---@field server GameServer
GameMatchMgr = GameMatchMgr or class("GameMatchMgr", GameServerLogicEntity)

function GameMatchMgr:ctor(logics, logic_name)
    GameMatchMgr.super.ctor(self, logics, logic_name)
    ---@type GameRoleMgr
    self._role_mgr = nil
    ---@type GameRoomMgr
    self._room_mgr = nil
    ---@type table<number, GameMatchItem>
    self._uid_match_map = {}
end


function GameMatchMgr:_on_init()
    GameMatchMgr.super._on_init(self)
    self._role_mgr = self.logics.role_mgr
    self._room_mgr = self.logics.room_mgr
end

function GameMatchMgr:_on_start()
    GameMatchMgr.super._on_start(self)
end

function GameMatchMgr:_on_stop()
    GameMatchMgr.super._on_stop(self)
end

function GameMatchMgr:_on_release()
    GameMatchMgr.super._on_release(self)
end

function GameMatchMgr:_on_update()
    GameMatchMgr.super._on_update(self)
end


--- 客户端函数
function GameMatchMgr:_on_map_client_msg_handle_fns()
    GameMatchMgr.super._on_map_client_msg_handle_fns(self)
    self._pid_to_client_msg_handle_fns[Fight_Pid.req_join_match] = self._on_msg_join_match
    self._pid_to_client_msg_handle_fns[Fight_Pid.req_quit_match] = self._on_msg_quit_match
end


function GameMatchMgr:_on_msg_join_match(from_gate, gate_netid, role_id, pid, msg)

end

function GameMatchMgr:_on_msg_quit_match(from_gate, gate_netid, role_id, pid, msg)

end

function GameMatchMgr:_on_msg_query_match_state(from_gate, gate_netid, role_id, pid, msg)

end

function GameMatchMgr:sync_state(role_id)

end



