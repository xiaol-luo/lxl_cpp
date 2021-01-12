
---@class UIPlatformPanel:UIPanelBase
UIPlatformPanel = UIPlatformPanel or class("UIPlatformPanel", UIPanelBase)

function UIPlatformPanel:ctor(panel_mgr, panel_setting)
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

function UIPlatformPanel:_on_init()
    UIPlatformPanel.super._on_init(self)

    self._gate_data_list = {
        {
            name = "win本地",
            platform_ip = "127.0.0.1",
            platform_port = 30002,
        },
        {
            name = "linux虚拟机",
            platform_ip = "192.168.0.11",
            platform_port = 30002,
        },
    }
end

function UIPlatformPanel:_on_attach_panel()
    UIPlatformPanel.super._on_attach_panel(self)
    self._account_id_if = UIHelp.attach_ui(UIInputIField, self._panel_root, "login_view/account_id")
    self._account_id_if:set_text(1)

    self._platform_ip_if = UIHelp.attach_ui(UIInputIField, self._panel_root, "login_view/platform_ip")
    self._platform_port_if = UIHelp.attach_ui(UIInputIField, self._panel_root, "login_view/platform_port")
    self._confirm_btn = UIHelp.attach_ui(UIButton, self._panel_root, "login_view/confirm_btn")

    self._confirm_btn:set_onclick(Functional.make_closure(self.on_click_confirm_btn, self))
    self._notify_txt = UIHelp.attach_ui(UIText, self._panel_root, "notify_txt")

    self._advise__content_ts = UIHelp.find_transform(self._panel_root, "advise_platforms/scroll_view/Viewport/Content")
    self._advise_item_prefab = UIHelp.find_gameobject(self._panel_root, "advise_platforms/scroll_view/Viewport/Content/item")
    UIHelp.set_active(self._advise_item_prefab, false)


    -- for i=1, 20
    do
        local is_selected = false
        for _, v in pairs(self._gate_data_list) do
            local item = UIHelp.clone_gameobject(self._advise_item_prefab)
            UIHelp.set_parent(item, self._advise__content_ts)
            local btn = UIHelp.attach_ui(UIButton, item, "")
            btn:set_onclick(Functional.make_closure(self._on_click_gate_data_item, self, v))
            UIHelp.attach_ui(UIText, item, "name"):set_text(v.name)
            UIHelp.attach_ui(UIText, item,"host"):set_text(string.format("%s:%s", v.platform_ip, v.platform_port))

            if not is_selected then
                is_selected = true
                self:_on_click_gate_data_item(v)
            end
        end
    end
end

function UIPlatformPanel:_on_open(panel_data)
    UIPlatformPanel.super._on_open(self, panel_data)
end

function UIPlatformPanel:_on_enable()
    UIPlatformPanel.super._on_enable(self)
end

function UIPlatformPanel:_on_disable()
    UIPlatformPanel.super._on_disable(self)
end

function UIPlatformPanel:_on_release()
    UIPlatformPanel.super._on_release(self)
end

function UIPlatformPanel:_on_click_gate_data_item(gate_data)
    self._platform_ip_if:set_text(gate_data.platform_ip)
    self._platform_port_if:set_text(gate_data.platform_port)
end

function UIPlatformPanel:on_click_confirm_btn()
    local account_id = self._account_id_if:get_text()
    if #account_id <= 0 then
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

    self._game_platform_net._account_id = account_id
    self._game_platform_net._platform_ip = platform_ip
    self._game_platform_net._platform_port = platform_port
    self._game_platform_net:login()
end

function UIPlatformPanel:_notify_error(error_msg)
    self._notify_txt:set_text(error_msg)
end





