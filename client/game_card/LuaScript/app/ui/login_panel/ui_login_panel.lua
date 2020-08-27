
---@class UILoginPanel:UIPanelBase
UILoginPanel = UILoginPanel or class("UILoginPanel", UIPanelBase)

function UILoginPanel:ctor(panel_mgr, panel_setting)
    self.super.ctor(self, panel_mgr, panel_setting)
    self._ip_txt = nil
    self._port_txt = nil
    self._cnn_btn = nil
    self._reset_btn = nil
    self._notify_txt = nil
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
            login_ip = "127.0.0.1",
            login_port = 31001,
        },
        {
            name = "linux虚拟机",
            login_ip = "192.168.0.11",
            login_port = 31001,
        },
    }
end

function UILoginPanel:_on_attach_panel()
    UILoginPanel.super._on_attach_panel(self)
    self._notify_txt = UIHelp.attach_ui(UIText, self._panel_root, "notify_txt")
    self._account_id_txt = UIHelp.attach_ui(UIText, self._panel_root, "login_view/account_id")
    self._account_id_txt:set_text(self._app.net_mgr.game_platform_net:get_account_id())
    self._confirm_btn = UIHelp.attach_ui(UIButton, self._panel_root, "login_view/confirm_btn")
    self._confirm_btn:set_onclick(Functional.make_closure(self.on_click_confirm_btn, self))
    self._ip_if = UIHelp.attach_ui(UIInputIField, self._panel_root, "login_view/login_ip")
    self._port_if = UIHelp.attach_ui(UIInputIField, self._panel_root, "login_view/login_port")

    self._advise_content_ts = UIHelp.find_transform(self._panel_root, "advise_logins/scroll_view/Viewport/Content")
    self._advise_item_prefab = UIHelp.find_gameobject(self._panel_root, "advise_logins/scroll_view/Viewport/Content/item")
    UIHelp.set_active(self._advise_item_prefab, false)

    -- for i=1, 20
    do
        local is_selected = false
        for _, v in pairs(self._gate_data_list) do
            local item = UIHelp.clone_gameobject(self._advise_item_prefab)
            UIHelp.set_parent(item, self._advise_content_ts)
            local btn = UIHelp.attach_ui(UIButton, item, "")
            btn:set_onclick(Functional.make_closure(self._on_click_gate_data_item, self, v))
            UIHelp.attach_ui(UIText, item, "name"):set_text(v.name)
            UIHelp.attach_ui(UIText, item,"host"):set_text(string.format("%s:%s", v.login_ip, v.login_port))

            if not is_selected then
                is_selected = true
                self:_on_click_gate_data_item(v)
            end
        end
    end
end

function UILoginPanel:_on_open(panel_data)
    UILoginPanel.super._on_open(self, panel_data)
end

function UILoginPanel:_on_enable()
    UILoginPanel.super._on_enable(self)
end

function UILoginPanel:_on_disable()
    UILoginPanel.super._on_disable(self)
end

function UILoginPanel:_on_release()
    UILoginPanel.super._on_release(self)
end

function UILoginPanel:_on_click_gate_data_item(gate_data)
    self._ip_if:set_text(gate_data.login_ip)
    self._port_if:set_text(gate_data.login_port)
end

function UILoginPanel:on_click_confirm_btn()
    local login_port = tonumber(self._port_if:get_text())
    if not login_port then
        self:_notify_error(string.format("login_port is not valid, %s", self._port_if:get_text()))
        return
    end
    local login_ip = self._ip_if:get_text()
    if not is_string(login_ip) or  #login_ip <= 0 then
        self:_notify_error(string.format("login_ip is not valid, %s", login_ip))
        return
    end

    self._game_login_net._login_ip = login_ip
    self._game_login_net._login_port = login_port
    self._game_login_net:login()
end

function UILoginPanel:_notify_error(error_msg)
    self._notify_txt:set_text(error_msg)
end





