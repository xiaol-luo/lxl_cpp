
---@alias Fn_RpcRemoteCallGameServerCallback fun(rpc_error_num:number, error_num:number ...):void

---@class RpcService: ServiceBase
RpcService = RpcService or class("RpcService", ServiceBase)

function RpcService:ctor(service_mgr, service_name)
    RpcService.super.ctor(self, service_mgr, service_name)
    self._next_unique_id = make_sequence(0)
    ---@type ProtoParser
    self._pto_parser = self.server.pto_parser
    ---@type RpcServiceRpcMgr
    self._rpc_mgr = RpcServiceRpcMgr:new(self)
end

function RpcService:_on_init()
    RpcService.super._on_init(self)
    self._pto_parser:load_files(Rpc_Pto.pto_files)
    self._pto_parser:setup_id_to_protos(Rpc_Pto.id_to_pto)
    self._rpc_mgr:init()

--[[    -- for test
    self:set_remote_call_handle_fn("hello", function(rpc_rsp, ...)
        log_print("handle remote call hello, params=", ...)
        rpc_rsp:response(Error_None, "test", ...)
    end)]]
end

function RpcService:_on_start()
    RpcService.super._on_start(self)
end

function RpcService:_on_stop()
    RpcService.super._on_stop(self)
end

function RpcService:_on_release()
    RpcService.super._on_release(self)
    self._rpc_mgr:destory()
end

function RpcService:_on_update()
    RpcService.super._on_update(self)
    self._rpc_mgr:on_frame()

--[[    -- for test
    local client = self:create_random_client(Server_Role.World)
    if client then
        client:call(function (rpc_error_num, ...)
            log_print("remote call callback ", rpc_error_num, ...)
        end, "hello", "world")
    end]]
end

---@param fn_name string
---@param fn Fn_RpcRemoteCallHandleFn
function RpcService:set_remote_call_handle_fn(fn_name, fn)
    self._rpc_mgr:set_remote_call_handle_fn(fn_name, fn)
end

---@param fn_name string
---@param fn Fn_RpcRemoteCallHandleFn
function RpcService:set_remote_call_coro_handle_fn(fn_name, fn)
    self._rpc_mgr:set_remote_call_coro_handle_fn(fn_name, fn)
end

---@param cb_fn Fn_RpcRemoteCallCallback
function RpcService:call(cb_fn, remote_server_key, remote_fn, ...)
    self._rpc_mgr:call(cb_fn, remote_server_key, remote_fn, ...)
end

---@param cb_fn Fn_RpcRemoteCallGameServerCallback
function RpcService:call_game_server(cb_fn, role_id, remote_fn, ...)
    -- todo: 因为pick_server_key 所以rpc到game_server可能无序，需要想办法使其有序
    local world_server_key = self.server.peer_net:pick_server_key(Server_Role.World, role_id)
    if not world_server_key then
        if cb_fn then
            cb_fn(Error_None, Error_Not_Available_Server)
            return
        end
    end

    local n, params = Functional.varlen_param_info(...)
    self:call(function(rpc_error_num, role_locations)
        local role_locate_game_server_key = role_locations[role_id]
        local not_find_role = not role_locate_game_server_key or #role_locate_game_server_key <= 0
        if Error_None ~= rpc_error_num or not_find_role then
            if cb_fn then
                cb_fn(rpc_error_num, not_find_role and Error_Not_Find_Role or Error_None)
            end
        else
            self:call(cb_fn, role_locate_game_server_key, remote_fn, table.unpack(params, 1, n))
        end
    end, world_server_key, Rpc.world.method.query_game_role_location, { role_id }, 3)
end

---@return RpcClient
function RpcService:create_client(remote_server_key)
    local ret = RpcClient:new(self._rpc_mgr, remote_server_key)
    return ret
end

---@return RpcClient
function RpcService:create_random_client(server_role)
    local ret = nil
    local remote_server_key = self.server.peer_net:random_server_key(server_role)
    if remote_server_key then
        ret = RpcClient:new(self._rpc_mgr, remote_server_key)
    end
    return ret
end

---@return RpcServiceProxy
function RpcService:create_svc_proxy()
    local ret = RpcServiceProxy:new(self)
    return ret
end
