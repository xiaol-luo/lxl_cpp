

---@class MatchTeamBase
---@field match_key string
---@field extra_params table<string, string>
---@field teammate_role_ids table<number, number>
---@field match_logic MatchLogicBase
MatchTeamBase = MatchTeamBase or class("MatchTeamBase")

function MatchTeamBase:ctor(match_logic, match_key, ask_role_id, teammate_role_ids, extra_params)
    self.match_logic = match_logic
    self.ask_role_id = ask_role_id
    self.match_key = match_key
    self.teammate_role_ids = teammate_role_ids
    self.extra_params = extra_params
end

---@field fn fun(role_id:number):void
function MatchTeamBase:foreach_role(fn, ...)
    for _, v in ipairs(self.teammate_role_ids) do
        fn(v, ...)
    end
end

---@param rpc_proxy RpcServiceProxy
---@param cb_fn Fn_RpcRemoteCallGameServerCallback
---@param rpc_method string
function MatchTeamBase:foreach_role_rpc_call(rpc_proxy, cb_fn, remote_fn, ...)
    for _, v in ipairs(self.teammate_role_ids) do
        rpc_proxy:call_game_server(cb_fn, v, remote_fn, ...)
    end
end


