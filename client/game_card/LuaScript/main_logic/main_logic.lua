
require("role.role")
require("role.role_mgr")
require("game_net.game_net")

local ItemMgr = require("item.item_mgr")
local Item = require("item.item")

local ACCOUNT_ID = "LXL_1"
local APPID_ID = "FOR_TEST_APP_ID"
local PLATFORM_NAME = "FOR_TEST_PLATFORM_NAME"
local TOKEN = "FOR_TEST_TOKEN"

MainLogic = MainLogic or class("MainLogic")

function MainLogic:ctor()
    self.role_mgr = nil
    self.item_mgr = nil
    self.game_net = nil
    self.is_first_update = true
    self.pb_loader = pb_protoc:new()
    self.pb_parser = pb
    self.login_net = nil
    self.login_rsp_msg = nil
end

function MainLogic:init()
    self.role_mgr = RoleMgr:new()
    self.role_mgr:add_role(Role:new())

    self.item_mgr = ItemMgr:new()
    self.item_mgr:add_item(Item:new())

    self.game_net = GameNet:new(
            Functional.make_closure(MainLogic.on_game_net_open, self),
            Functional.make_closure(MainLogic.on_game_net_close, self),
            Functional.make_closure(MainLogic.on_game_net_recv_msg, self)
    )
    self.login_net = GameNet:new(
            Functional.make_closure(MainLogic.on_login_net_open, self),
            Functional.make_closure(MainLogic.on_login_net_close, self),
            Functional.make_closure(MainLogic.on_login_net_recv_msg, self)
    )
    local pb_search_path = path.combine(CS.Application.dataPath, "../GameData/proto")
    self.pb_loader:addpath(pb_search_path)
    for _, v in ipairs({
        "test_pb.txt",
        "client_gate.pb",
        "client_login.pb",
    }) do
        self.pb_loader:loadfile(v)
    end
end

function MainLogic:on_frame()
    if self.is_first_update then
        self.is_first_update = false
        self.login_net:connect("127.0.0.1", 31001)
    end
    self.role_mgr:tick_role()
    self.item_mgr:tick_item()

    local xx = CS.Lua.LuaResLoaderProxy.Create()
    local ee = xx:GetLoadedResState("1234")
end

function MainLogic:on_game_net_open(is_succ)
    print("MainLogic:on_game_net_open", is_succ)
    if is_succ then
        if true then
            local bin = self.pb_parser.encode("ReqUserLogin", {
                user_id = self.login_rsp_msg.user_id,
                app_id = APPID_ID,
                auth_sn = self.login_rsp_msg.auth_sn,
                auth_ip = self.login_rsp_msg.auth_ip,
                auth_port = self.login_rsp_msg.auth_port,
                account_id = ACCOUNT_ID,
                ignore_auth = true,
            })
            print("bin", #bin, self.pb_parser.decode("ReqUserLogin", bin))
            self.game_net:send(20000, bin)
        end
    end
end

function MainLogic:on_game_net_close(error_num, error_msg)
    print("MainLogic:on_game_net_close", error_num, error_msg)
end

function MainLogic:on_game_net_recv_msg(proto_id, bytes, data_len)
    print("MainLogic:on_game_net_recv_msg", proto_id, tostring(data_len), type(bytes), bytes)

    if proto_id == 20001 then
        local xxx = self.pb_parser.decode("RspUserLogin", bytes)
        print("xxxxxxxxx", string.toprint(xxx))
    end
end

function MainLogic:on_login_net_open(is_succ)
    print("MainLogic:on_login_net_open", is_succ)
    if is_succ then
        if true then
            local bin = self.pb_parser.encode("ReqLoginGame", {
                token = TOKEN,
                timestamp = os.time(),
                platform = PLATFORM_NAME,
                ignore_auth = true,
                force_account_id = ACCOUNT_ID,
            })
            print("bin", #bin, self.pb_parser.decode("ReqLoginGame", bin))
            self.login_net:send(10000, bin)
        end
    end
end

function MainLogic:on_login_net_close(error_num, error_msg)
    print("MainLogic:on_login_net_close", error_num, error_msg)
end

function MainLogic:on_login_net_recv_msg(proto_id, bytes, data_len)
    print("MainLogic:on_login_net_recv_msg", proto_id, tostring(data_len), type(bytes), bytes)

    if proto_id == 10001 then
        local msg = self.pb_parser.decode("RspLoginGame", bytes)
        if 0 == msg .error_code then
            self.game_net:connect("127.0.0.1", 32001)
            self.login_rsp_msg = msg
        else
            log_error("login fail!")
        end
        self.login_net:close()
    end
end

print("reach MainLogic")