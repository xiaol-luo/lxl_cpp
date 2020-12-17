
---@class FightClientMgr:GameLogicEntity
---@field server FightServer
FightClientMgr = FightClientMgr or class("FightClientMgr", GameLogicEntity)

function FightClientMgr:ctor(logics, logic_name)
    FightClientMgr.super.ctor(self, logics, logic_name)
    ---@type table<number, FightClient>
    self._fight_clients = {}
    ---@type ClientNetService
    self._client_net_svc = self.server.client_net
    ---@type ProtoParser
    self._pto_parser = self.server.pto_parser

    ---@type table<number, Fn_FightClientMsgHandler>
    self._msg_handlers = {}
end

function FightClientMgr:_on_init()
    FightClientMgr.super._on_init(self)
    -- self:setup_proto_handler()

    ---@type ClientNetServiceCnnCallback
    local cnn_cbs = {}
    cnn_cbs.on_open = Functional.make_closure(self._client_net_svc_cnn_on_open, self)
    cnn_cbs.on_close = Functional.make_closure(self._client_net_svc_cnn_on_close, self)
    cnn_cbs.on_recv = Functional.make_closure(self._client_net_svc_cnn_on_recv, self)
    self._client_net_svc:set_cnn_cbs(cnn_cbs)
end

function FightClientMgr:_on_start()
    FightClientMgr.super._on_start(self)
end

function FightClientMgr:_on_stop()
    FightClientMgr.super._on_stop(self)
end

function FightClientMgr:_on_release()
    FightClientMgr.super._on_release(self)
end

function FightClientMgr:_on_update()
    FightClientMgr.super._on_update(self)
end

---@param client_net_svc ClientNetService
function FightClientMgr:_client_net_svc_cnn_on_open(client_net_svc, netid)
    -- log_print("FightClientMgr:_client_net_svc_cnn_on_open", netid)
    local cnn = client_net_svc:get_cnn(netid)
    if not cnn then
        return
    end

    if self._fight_clients[netid] then
        log_error("FightClientMgr:_client_net_svc_cnn_on_open unknown error: repeated netid %s", netid)
        Net.close(netid)
        return
    end

    local fight_client = FightClient:new(cnn)
    self._fight_clients[netid] = fight_client
end

function FightClientMgr:_client_net_svc_cnn_on_close(client_net_svc, netid, error_code)
    local fight_client = self._fight_clients[netid]
    if not fight_client then
        return
    end
    self._fight_clients[netid] = nil
    -- 抛事件
end

function FightClientMgr:_client_net_svc_cnn_on_recv(client_net_svc, netid, pid, bin)
    local handle_fn = self._msg_handlers[pid]
    if not handle_fn then
        log_warn("FightClientMgr:_client_net_svc_cnn_on_recv not set handle function for pid %s", pid)
        return
    end

    local fight_client = self._fight_clients[netid]
    if not fight_client then
        local cnn = client_net_svc:get_cnn(netid)
        if cnn then
            Net.close(netid)
        end
        return
    end

    local is_ok, msg = true, nil
    if self._pto_parser:exist(pid) then
        is_ok, msg = self._pto_parser:decode(pid, bin)
    end
    if is_ok then
        handle_fn(fight_client, pid, msg)
    end
end

function FightClientMgr:get_client(netid)
    return self._fight_clients[netid]
end

---@param handler Fn_FightClientMsgHandler
function FightClientMgr:set_msg_handler(pid, handler)
    if handler then
        assert(is_function(handler))
        assert(not self._msg_handlers[pid])
    end
    self._msg_handlers[pid] = handler
end
