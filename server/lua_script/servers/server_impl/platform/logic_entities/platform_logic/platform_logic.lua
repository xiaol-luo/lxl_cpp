
--[[
这是一个模拟的平台，因此
1.所有的login_platform请求都会成功
2.会为每次成功的login_platform生成一个token，存在_token_map。以作为verity_token的数据源
3.auth_token时，只要token->timestamp 匹对，则认为验证通过，其他为认证失败。
4.所有key采用小写
--]]

---@class PlatformLogic:GameLogicEntity
---@field server PlatformServer
---@field logics PlatformLogicService
PlatformLogic = PlatformLogic or class("PlatformLogic", LogicEntityBase)

function PlatformLogic:ctor(logics, logic_name)
    PlatformLogic.super.ctor(self, logics, logic_name)
    ---@type HttpNetServiceProxy
    self._http_net_proxy = nil
    self._token_map = {}
end

function PlatformLogic:_on_init()
    PlatformLogic.super._on_init(self)
    self._http_net_proxy = self.server.http_net:create_proxy()
end

function PlatformLogic:_on_start()
    PlatformLogic.super._on_start(self)
    self._http_net_proxy:set_handle_fn(Platform_Http_Method.login_platform, Functional.make_closure(self._on_http_login_platform, self))
    self._http_net_proxy:set_handle_fn(Platform_Http_Method.verity_token, Functional.make_closure(self._on_http_verity_token, self))
end

function PlatformLogic:_on_stop()
    PlatformLogic.super._on_stop(self)
    self._http_net_proxy:clear_all()
end

function PlatformLogic:_on_release()
    PlatformLogic.super._on_release(self)
end

function PlatformLogic:_on_update()
    PlatformLogic.super._on_update(self)

end

function PlatformLogic:_http_rsp_help(cnn_id, body)
    local body_str = body
    if is_table(body) then
        body_str = lua_json.encode(body)
    end
    Net.send(cnn_id, gen_http_rsp_content(200, "ok", body_str))
end

---@param from_cnn_id number
---@param method HttpMethod
---@param req_url string
---@param heads_map table<string, string>
---@param body string
function PlatformLogic:_on_http_login_platform(from_cnn_id, method, req_url, heads_map, body)
    local platform_account_id = heads_map["platform_account_id"]
    local password = heads_map["password"]
    local game_id = heads_map["game_id"]
    if not platform_account_id or not game_id then
        self:_http_rsp_help(from_cnn_id, {
            error_num = 1,
            error_msg = "platform_account_id or game_id is not valid",
        })
    else
        local token_str = gen_uuid()
        local timestamp_str = tostring(os.time())
        self._token_map[token_str] = {
            timestamp = timestamp_str,
            platform_account_id = platform_account_id,
            game_id = game_id,
        }
        local rsp_body = {
            error_num = 0,
            error_msg = nil,
            timestamp = timestamp_str,
            token = token_str,
        }
        self:_http_rsp_help(from_cnn_id, rsp_body)
    end
    Net.close(from_cnn_id)
end

---@param from_cnn_id number
---@param method HttpMethod
---@param req_url string
---@param heads_map table<string, string>
---@param body string
function PlatformLogic:_on_http_verity_token(from_cnn_id, method, req_url, heads_map, body)
    local token_str = heads_map["token"]
    local timestamp_str = heads_map["timestamp"]

    if not token_str or not timestamp_str then
        self:_http_rsp_help(from_cnn_id, {
            error_num = 1,
            error_msg = "token or timestamp_str is not valid",
        })
    else
        local token_item = self._token_map[token_str]
        -- log_print("PlatformLogic:_on_http_verity_token ", token_item, timestamp_str, token_str, heads_map)
        if not token_item or token_item.timestamp ~= timestamp_str then
            self:_http_rsp_help(from_cnn_id, {
                error_num = 1,
                error_msg = "token_str and timestamp_str is mismatch",
            })
        else
            self:_http_rsp_help(from_cnn_id, {
                error_num = 0,
                error_msg = nil,
                platform_account_id = token_item.platform_account_id,
                game_id = token_item.game_id,
            })
        end
    end
    Net.close(from_cnn_id)
end





