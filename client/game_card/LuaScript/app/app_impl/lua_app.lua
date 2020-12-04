---@class LuaApp:EventMgr
---@field state_mgr AppStateMgr
---@field panel_mgr UIPanelMgr
---@field net_mgr NetMgr
---@field data_mgr DataMgr
---@field pto_parser ProtoParser
LuaApp = LuaApp or class("LuaApp", EventMgr)

function LuaApp:ctor()
    LuaApp.super.ctor(self)

    self.panel_mgr = nil
    self.state_mgr = nil
    self.pto_parser = nil
    self.net_mgr = nil
    self.data_mgr = nil
end

function LuaApp:init(arg)
    for _, v in pairs(require("app.app_impl.lua_app_pre_require_server_files")) do
        include_file(v)
    end

    include_file("app.include")
    require("app.ui.ui_panel_setting")

    log_assert(self:init_proto_parser(), "init_proto_parser fail")

    local ui_root = CS.UnityEngine.GameObject.FindObjectOfType(typeof(CS.Utopia.UIRoot))
    log_assert(CSharpHelp.not_null(ui_root), "not found CS.Utopia.UIRoot")
    self.panel_mgr = UIPanelMgr:new()
    self.panel_mgr:init(ui_root.gameObject)

    self.net_mgr = NetMgr:new(self)
    self.net_mgr:init()

    self.data_mgr = DataMgr:new(self)
    self.data_mgr:init()

    self.state_mgr = AppStateMgr:new(self)
    self.state_mgr:init()
end

function LuaApp:_on_start()
    self.state_mgr:change_state(App_State_Name.init)
end

function LuaApp:_on_update()
    if self.state_mgr then
        self.state_mgr:update_state()
    end
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
    self:cancel_all()
end

function LuaApp:stop()
    self:_on_stop()
end

function LuaApp:init_proto_parser()
    self.pto_parser = ProtoParser:new()
    self.pto_parser:add_search_dirs({
        path.combine(CS.UnityEngine.Application.dataPath, "../ServerData", "proto")
    })

    assert(self.pto_parser:load_files(Login_Pto.pto_files))
    self.pto_parser:setup_id_to_protos(Login_Pto.id_to_pto)

    assert(self.pto_parser:load_files(Forward_Msg_Pto.pto_files))
    self.pto_parser:setup_id_to_protos(Forward_Msg_Pto.id_to_pto)

    assert(self.pto_parser:load_files(Main_Role_Pto.pto_files))
    self.pto_parser:setup_id_to_protos(Main_Role_Pto.id_to_pto)

    assert(self.pto_parser:load_files(Fight_Pto.pto_files))
    self.pto_parser:setup_id_to_protos(Fight_Pto.id_to_pto)

    return true
end
