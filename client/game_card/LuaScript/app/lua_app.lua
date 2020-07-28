---@class LuaApp
LuaApp = LuaApp or class("LuaApp", EventMgr)

function LuaApp:ctor()
    LuaApp.super.ctor(self)

    self.game_net = nil
    self.login_net = nil
    self.login_rsp_msg = nil

    self.ui_panel_mgr = nil
    self.msg_event_mgr = nil
    self.state_mgr = nil
    self.proto_parser = nil
    self.login_cnn_logic = nil
    self.gate_cnn_logic = nil
    self.fight_cnn_logic = nil
    self.role_mgr = nil
    self.main_role = nil
    self.main_user = nil
end

function LuaApp:init(arg)
    local pre_require_files = require("app.pre_require_files")
    for _, v in pairs(pre_require_files) do
        require(v)
    end

    self.ui_panel_mgr = UIPanelMgr:new()
    self.state_mgr = LuaAppStateMgr:new(self)
    self.state_mgr:init()

    --[[
    log_assert(self:init_proto_parser(), "init_proto_parser fail")
    UI_Panel_Setting_Help.adjust_setting()

    self.event_mgr = EventMgr:new()
    self.msg_event_mgr = EventMgr:new()
    local ui_root = CS.UnityEngine.GameObject.FindObjectOfType(typeof(CS.Utopia.UIRoot))
    log_assert(CSharpHelp.not_null(ui_root), "not found CS.Utopia.UIRoot")
    self.ui_panel_mgr:init(ui_root.gameObject)

    self.role_mgr = RoleMgr:new(self)
    self.role_mgr:init()

    self.main_role = MainRole:new(self)
    self.main_role:init()

    self.main_user = MainUser:new(self)
    self.main_user:init()

    self.login_cnn_logic = LoginCnnLogic:new(self)
    self.gate_cnn_logic = GateCnnLogic:new(self)
    self.fight_cnn_logic = FightCnnLogic:new(self)
    ]]
end

function LuaApp:_on_start()
    --self.state_mgr:change_state(App_State_Name.init_game)
end

function LuaApp:_on_update()
    -- self.state_mgr:update_state()
end

function LuaApp:_on_stop()

end

function LuaApp:_on_release()

end

function LuaApp:start()
    self:_on_start()
end

function LuaApp:update()
    self:_on_update()
end

function LuaApp:release()
    self:_on_release()
end

function LuaApp:stop()
    self:_on_stop()
end

function LuaApp:init_proto_parser()
    local proto_dir = path.combine(CS.Application.dataPath, "../GameData/proto")
    local proto_files  = get_game_proto_files()
    local pid_proto_map = get_game_pid_proto_map()
    self.proto_parser = parse_proto({ proto_dir }, proto_files, pid_proto_map)
    return nil ~= self.proto_parser
end
