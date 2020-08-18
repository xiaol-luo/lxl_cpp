
---@class UILoginPanel:UIPanelBase
UILoginPanel = UILoginPanel or class("UILoginPanel", UIPanelBase)

function UILoginPanel:ctor(panel_mgr, panel_setting)
    self.super.ctor(self, panel_mgr, panel_setting)
    self._ip_txt = nil
    self._port_txt = nil
    self._cnn_btn = nil
    self._reset_btn = nil
    self._notify_txt = nil
    self._user_info = nil
    self._account_id_txt = nil

    ---@type GamePlatformNetEditor
    self._game_platform_net = self._app.net_mgr.game_platform_net
    ---@type GameLoginNetEditor
    self._game_login_net = self._app.net_mgr.game_login_net
end

function UILoginPanel:_on_init()
    log_debug("UILoginPanel:init")
    UILoginPanel.super._on_init(self)

    self._gate_data_list = {
        {
            name = "win本地",
            platform_ip = "127.0.0.1",
            platform_port = 30002,
            gate_ip = "127.0.0.1",
            gate_port = 35001,
        },
        {
            name = "linux虚拟机",
            platform_ip = "192.168.0.11",
            platform_port = 30002,
            gate_ip = "192.168.0.11",
            gate_port = 35001,
        },
    }
end

function UILoginPanel:_on_attach_panel()
    UILoginPanel.super._on_attach_panel(self)
    self._account_id_if = UIHelp.attach_ui(UIInputIField, self._panel_root, "login_view/account_id")
    self._platform_ip_if = UIHelp.attach_ui(UIInputIField, self._panel_root, "login_view/platform_ip")
    self._platform_port_if = UIHelp.attach_ui(UIInputIField, self._panel_root, "login_view/platform_port")
    self._confirm_btn = UIHelp.attach_ui(UIButton, self._panel_root, "login_view/confirm_btn")
    self._gate_ip_if = UIHelp.attach_ui(UIInputIField, self._panel_root, "login_view/gate_ip")
    self._gate_port_if = UIHelp.attach_ui(UIInputIField, self._panel_root, "login_view/gate_port")

    self._confirm_btn:set_onclick(Functional.make_closure(self.on_click_confirm_btn, self))
    self._notify_txt = UIHelp.attach_ui(UIText, self._panel_root, "notify_txt")

    self._advise_gates_content_ts = UIHelp.find_transform(self._panel_root, "advise_gates/advise_gates_scroll_view/Viewport/Content")
    self._advise_gates_item_prefab = UIHelp.find_gameobject(self._panel_root, "advise_gates/advise_gates_scroll_view/Viewport/Content/item")
    UIHelp.set_active(self._advise_gates_item_prefab, false)

    -- for i=1, 20
    do
        for _, v in pairs(self._gate_data_list) do
            local item = UIHelp.clone_gameobject(self._advise_gates_item_prefab)
            UIHelp.set_parent(item, self._advise_gates_content_ts)
            local btn = UIHelp.attach_ui(UIButton, item, "")
            btn:set_onclick(Functional.make_closure(self._on_click_gate_data_item, self, v))
            UIHelp.attach_ui(UIText, item, "gate_name"):set_text(v.name)
            UIHelp.attach_ui(UIText, item,"gate_host"):set_text(string.format("platform=%s:%s;gate=%s:%s",
                    v.platform_ip, v.platform_port,  v.gate_ip, v.gate_port))
        end
    end
end

function UILoginPanel:_on_open(panel_data)
    UILoginPanel.super._on_open(self, panel_data)

    log_info("UILoginPanel:on_show")

    --self.ml_event_subscriber:subscribe(Event_Set__Login_Cnn_Logic.login_done, Functional.make_closure(self.on_event_login_cnn_done, self))
    --self.ml_event_subscriber:subscribe(Event_Set__Login_Cnn_Logic.open, Functional.make_closure(self.on_event_login_cnn_open, self))
    --self.ml_event_subscriber:subscribe(Event_Set__Login_Cnn_Logic.close, Functional.make_closure(self.on_event_login_cnn_close, self))
end

function UILoginPanel:_on_enable()
    UILoginPanel.super._on_enable(self)
    log_info("UILoginPanel:_on_enable")
    -- self.ml_event_subscriber:release_all()
end

function UILoginPanel:_on_disable()
    UILoginPanel.super._on_disable(self)
    log_info("UILoginPanel:_on_disable")
    -- self.ml_event_subscriber:release_all()
end

function UILoginPanel:_on_release()
    UILoginPanel.super._on_release(self)
    log_info("UILoginPanel:on_release")
    -- self.ml_event_subscriber:release_all()
end

function UILoginPanel:_on_click_gate_data_item(gate_data)
    log_print("UILoginPanel:_on_click_gate_data_item", gate_data)
    self._gate_ip_if:set_text(gate_data.gate_ip)
    self._gate_port_if:set_text(gate_data.gate_port)
    self._platform_ip_if:set_text(gate_data.platform_ip)
    self._platform_port_if:set_text(gate_data.platform_port)
end

function UILoginPanel:on_click_confirm_btn()
    log_print("UILoginPanel:on_click_confirm_btn")
    --local login_cnn_logic = g_ins.login_cnn_logic
    --local cnn_state = login_cnn_logic:get_state()
    --log_debug("UILoginPanel:on_click_cnn_btn state is %s", cnn_state)
    --if Net_Agent_State.free == cnn_state or Net_Agent_State.closed == cnn_state then
    --    login_cnn_logic:set_account_id(self.account_id_txt:get_text())
    --    login_cnn_logic:reset(self.ip_txt:get_text(), tonumber(self.port_txt:get_text()))
    --    login_cnn_logic:connect()
    --else
    --    log_error("login_cnn_logic in state %s", cnn_state)
    --end

    local account_id = tonumber(self._account_id_if:get_text())
    if not account_id then
        self:_notify_error(string.format("account is not valid, %s", self._account_id_if:get_text()))
        return
    end
    local platform_port = tonumber(self._platform_port_if:get_text())
    if not platform_port then
        self:_notify_error(string.format("platform_port is not valid, %s", self._platform_port_if:get_text()))
        return
    end
    local platform_ip = self._platform_ip_if:get_text()
    if not is_string(platform_ip) or  #platform_ip <= 0 then
        self:_notify_error(string.format("platform_ip is not valid, %s", platform_ip))
        return
    end
    local gate_port = tonumber(self._gate_port_if:get_text())
    if not gate_port then
        self:_notify_error(string.format("gate_port is not valid, %s", self._gate_port_if:get_text()))
        return
    end
    local gate_ip = self._gate_ip_if:get_text()
    if not is_string(gate_ip) or  #gate_ip <= 0 then
        self:_notify_error(string.format("gate_ip is not valid, %s", gate_ip))
        return
    end

    self._game_platform_net:logout()
    self._game_platform_net._account_id = account_id
    self._game_platform_net._platform_ip = platform_ip
    self._game_platform_net._platform_port = platform_port
    self._game_platform_net:login()

    --self._game_login_net:logout()
    --self._game_login_net._user_id = account_id
    --self._game_login_net._gate_hosts = { {ip = gate_ip, port = gate_port} }
    --self._game_login_net:login()

    -- log_print("______________", self._game_login_net:is_ready(), self._game_platform_net:is_ready())
end

function UILoginPanel:_notify_error(error_msg)
    self._notify_txt:set_text(error_msg)
end

function UILoginPanel:on_click_reset_btn()
    --log_info("UILoginPanel:on_click_reset_btn")
    --local login_cnn_logic = g_ins.login_cnn_logic
    --login_cnn_logic:reset(self.ip_txt:get_text(), tonumber(self.port_txt:get_text()))
    --self.notify_txt:set_text
end

function UILoginPanel:on_event_login_cnn_done(cnn_logic, error_code, user_info)
    --log_info("UILoginPanel:on_event_login_cnn_done")
    --self.user_info = user_info
    --if 0 ~= error_code then
    --    self.notify_txt:set_text(string.format("get user info from login game fail. error_code is %s", error_code))
    --end
end

function UILoginPanel:on_event_login_cnn_open(cnn_logic, is_succ)
    log_info("UILoginPanel:on_event_login_cnn_open %s", is_succ)
    if not is_succ then
        self.notify_txt:set_text("connect login server fail")
    end
end

function UILoginPanel:on_event_login_cnn_close(cnn_logic, error_code, error_msg)
    if not cnn_logic:is_done() and Error_None ~= error_code then
        self.notify_txt:set_text(string.format( "login connection closed unexpected ! error_msg : %s ", error_msg))
    end
end




