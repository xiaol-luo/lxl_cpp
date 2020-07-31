
UILaunchRolePanel = UILaunchRolePanel or class("UILaunchRolePanel", UIPanelBase)

function UILaunchRolePanel:ctor(panel_mgr, panel_setting, root_go)
    self.super.ctor(self, panel_mgr, panel_setting, root_go)

    self.notify_txt = nil
    self.create_role_btn = nil
    self.role_items = nil
    self.connect_gate_btn = nil
    self.goto_login_btn = nil

    self.ml_event_subscriber = nil
    self.msg_event_subscriber = nil
end

function UILaunchRolePanel:init()
    log_debug("UILaunchRolePanel:init")
    self.super.init(self)

    self.ml_event_subscriber = g_ins.event_mgr:create_subscriber()
    self.msg_event_subscriber = g_ins.msg_event_mgr:create_subscriber()

    self.notify_txt = UIHelp.attach_ui(UIText, self.root_go, "NotifyTxt")

    self.connect_gate_btn =  UIHelp.attach_ui(UIButton, self.root_go, "LaunchView/ConnectBtn")
    self.connect_gate_btn:set_onclick(Functional.make_closure(self.on_click_connect_gate_btn, self))

    self.goto_login_btn = UIHelp.attach_ui(UIButton, self.root_go, "LaunchView/GotoLogin")
    self.goto_login_btn:set_onclick(Functional.make_closure(self.on_click_goto_login_btn, self))

    self.create_role_btn = UIHelp.attach_ui(UIButton, self.root_go, "LaunchView/CreateRoleBtn")
    self.create_role_btn:set_onclick(Functional.make_closure(self.on_click_create_role_btn, self))
    self.role_items = {}
    for i=1, 3 do
        local role_name_txt = UIHelp.attach_ui(UIText, self.root_go, string.format("LaunchView/RoleItem_%s/RoleName", i))
        local launch_btn = UIHelp.attach_ui(UIButton, self.root_go, string.format("LaunchView/RoleItem_%s/LaunchBtn", i))
        self.role_items[i] = {
            role_name_txt = role_name_txt,
            launch_btn = launch_btn,
            data = nil,
        }
        launch_btn:set_onclick(Functional.make_closure(self.on_click_launch_btn, self, i))
    end
    self:refresh_role_digiests()
end


function UILaunchRolePanel:on_show(is_new_show, panel_data)
    log_info("UILaunchRolePanel:on_show")
    self.ml_event_subscriber:subscribe(Event_Set__Gate_Cnn_Logic.open, Functional.make_closure(self.on_event_gate_cnn_open, self))
    self.ml_event_subscriber:subscribe(Event_Set__Gate_Cnn_Logic.close, Functional.make_closure(self.on_event_gate_cnn_close, self))
    self.ml_event_subscriber:subscribe(Event_Set__Gate_Cnn_Logic.login_gate_result, Functional.make_closure(self.on_event_login_gate_result, self))


    self.ml_event_subscriber:subscribe(ProtoId.rsp_pull_role_digest, Functional.make_closure(self.on_msg_rsp_role_digests, self))
    self.ml_event_subscriber:subscribe(Game_User_Event.launch_role_result, Functional.make_closure(self.on_event_launch_role_result, self))

end

function UILaunchRolePanel:on_hide()
    log_info("UILaunchRolePanel:on_hide")
    self.ml_event_subscriber:release_all()
end

function UILaunchRolePanel:refresh_role_digiests()
    local i = 0
    for k, v in pairs(g_ins.main_user.role_digests or {}) do
        i = i + 1
        local role_item = self.role_items[i]
        role_item.data = v
        local role_name_txt = role_item.role_name_txt
        role_name_txt:set_text(v.role_id)
    end
end

function UILaunchRolePanel:on_click_launch_btn(idx)
    local role_item = self.role_items[idx]
    if not role_item or not role_item.data then
        log_error("no role data to launch")
        return
    end
    g_ins.main_user:launch_role(role_item.data.role_id)
end

function UILaunchRolePanel:on_click_create_role_btn()
    g_ins.main_user:create_role(nil)
end

function UILaunchRolePanel:on_click_connect_gate_btn()
    g_ins.gate_cnn_logic:connect()
end

function UILaunchRolePanel:on_click_goto_login_btn()
    log_debug("UILaunchRolePanel:on_click_goto_login_btn")
    g_ins.event_mgr:fire(Event_Set__State_InGame.try_enter_login_state)
end

function UILaunchRolePanel:on_event_gate_cnn_open(cnn_logic, is_succ)
    log_info("UILaunchRolePanel:on_event_gate_cnn_open %s", is_succ)
    if not is_succ then
        self.notify_txt:set_text("connect gate server fail")
    end
end

function UILaunchRolePanel:on_event_gate_cnn_close(cnn_logic, error_code, error_msg)
    log_info("on_event_gate_cnn_close error_num: %s error_msg: %s", error_code, error_msg)
    self.notify_txt:set_text("on_event_gate_cnn_close error_num: %s error_msg: %s", error_code, error_msg)
end

function UILaunchRolePanel:on_event_login_gate_result(cnn_logic, error_num)
    log_info("UILaunchRolePanel:on_event_login_gate_result %s", error_num)
    if Error_None ~= error_num then
        self.notify_txt:set_text("on_event_login_gate_result error_num: %s", error_num)
    end
end

function UILaunchRolePanel:on_msg_rsp_role_digests(cnn_logic, msg)
    self:refresh_role_digiests()
end

function UILaunchRolePanel:on_event_launch_role_result(cnn_logic, msg)
    log_debug("UILaunchRolePanel:on_event_rsp_launch_role %s", msg)
end



