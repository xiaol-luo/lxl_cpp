
MainLogic = MainLogic or class("MainLogic")

function MainLogic:ctor()
    self.game_net = nil
    self.login_net = nil
    self.login_rsp_msg = nil

    self.ui_panel_mgr = nil
    self.event_mgr = nil
    self.state_mgr = nil
    self.proto_parser = nil
    self.login_cnn_logic = nil
    self.gate_cnn_logic = nil
end

function MainLogic:init(arg)
    local pre_require_files = require("main_logic.main_logic_impl.pre_require_files")
    for _, v in pairs(pre_require_files) do
        require(v)
    end

    log_assert(self:init_proto_parser(), "init_proto_parser fail")
    UI_Panel_Setting_Help.adjust_setting()

    self.event_mgr = EventMgr:new()

    self.ui_panel_mgr = UIPanelMgr:new()
    local ui_root = CS.UnityEngine.GameObject.FindObjectOfType(typeof(CS.Utopia.UIRoot))
    log_assert(CSharpHelp.not_null(ui_root), "not found CS.Utopia.UIRoot")
    self.ui_panel_mgr:init(ui_root.gameObject)

    self.login_cnn_logic = LoginCnnLogic:new(self)
    self.gate_cnn_logic = GateCnnLogic:new(self)

    self.state_mgr = MainLogicStateMgr:new(self)
    self.state_mgr:init()
    self.state_mgr:change_state(Main_Logic_State_Name.init_game)

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
end

function MainLogic:init_proto_parser()
    local proto_dir = path.combine(CS.Application.dataPath, "../GameData/proto")
    local proto_files  = get_game_proto_files()
    local pid_proto_map = get_game_pid_proto_map()
    self.proto_parser = parse_proto({ proto_dir }, proto_files, pid_proto_map)
    return nil ~= self.proto_parser
end

function MainLogic:on_start()
    -- self.login_net:connect("127.0.0.1", 31001)
end

function MainLogic:on_update()
    self.state_mgr:update_state()
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
