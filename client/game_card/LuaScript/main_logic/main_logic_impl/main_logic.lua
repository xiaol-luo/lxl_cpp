

local ACCOUNT_ID = "LXL_1"
local APPID_ID = "FOR_TEST_APP_ID"
local PLATFORM_NAME = "FOR_TEST_PLATFORM_NAME"
local TOKEN = "FOR_TEST_TOKEN"

MainLogic = MainLogic or class("MainLogic")

function MainLogic:ctor()
    self.role_mgr = nil
    self.item_mgr = nil
    self.game_net = nil
    self.pb_loader = pb_protoc:new()
    self.pb_parser = pb
    self.login_net = nil
    self.login_rsp_msg = nil
    self.ui_panel_mgr = nil
    self.state_mgr = nil
end

function MainLogic:init(arg)
    local pre_require_files = require("main_logic.main_logic_impl.pre_require_files")
    for _, v in pairs(pre_require_files) do
        require(v)
    end

    self.state_mgr = MainLogicStateMgr:new(self)
    self.state_mgr:init()

    self.ui_panel_mgr = UIPanelMgr:new()
    local ui_root = CS.UnityEngine.GameObject.FindObjectOfType(typeof(CS.Utopia.UIRoot))
    self.ui_panel_mgr:init(ui_root.gameObject)

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

    UI_Panel_Setting_Help.adjust_setting()

    self.state_mgr:change_state(Main_Logic_State_Name.init_game)
end

function MainLogic:on_start()
    -- self.login_net:connect("127.0.0.1", 31001)

    -- local ui_root = CS.UnityEngine.GameObject.FindObjectOfType(typeof(CS.Utopia.UIRoot))
    -- UIHelp.get_component(typeof(CS.Utopia.UIRoot), ui_root)
    -- local ui_root_go = ui_root.gameObject
    -- self.ui_panel_mgr:init(ui_root_go)
    -- self.ui_panel_mgr:prepare_assets()
    -- self.ui_panel_mgr:show_panel(UI_Panel_Name.main_panel, {})
    -- self.ui_panel_mgr:release_panel(UI_Panel_Name.main_panel)

    -- local panel_proxy_go = CS.UnityEngine.GameObject.Find("UIPanelProxy")
    -- local mask_go = UIHelp.find_gameobject(panel_proxy_go, "Root/Mask")
    -- local panel_root_go = UIHelp.find_gameobject(panel_proxy_go, "Root/PanelRoot")
    -- mask_go:SetActive(true)
    -- mask_go:SetActive(false)
    -- local prg2 = CS.Lua.LuaHelp.InstantiateGameObject(panel_proxy_go)
    -- CS.UnityEngine.GameObject.DestroyImmediate(prg2)

    -- CS.UnityEngine.GameObject.DestroyImmediate(panel_proxy_root)
    -- print("local try_comp = UIComponent:new(prg2)")
    -- local try_comp = UIComponent:new(prg2)
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

print("reach MainLogic")