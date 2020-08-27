
---@class UIManageRolePanel:UIPanelBase
UIManageRolePanel = UIManageRolePanel or class("UIManageRolePanel", UIPanelBase)

function UIManageRolePanel:ctor(panel_mgr, panel_setting)
    self.super.ctor(self, panel_mgr, panel_setting)
    self._notify_txt = nil
    self._gate_state_txt = nil
    self._gate_cnn_btn = nil
    self._re_login_btn = nil

    self._role_list_content_ts = nil
    self._role_list_content_item_prefab = nil
    self._role_list_items = {}

    self._create_role_btn = nil
    self._launch_role_btn = nil
    self._role_detail_role_id_txt = nil

    ---@type GamePlatformNetEditor
    self._platform_net = self._app.net_mgr.game_platform_net
    ---@type GameLoginNetEditor
    self._login_net = self._app.net_mgr.game_login_net
    ---@type GameGateNetEditor
    self._gate_net = self._app.net_mgr.game_gate_net

    self._selected_role_id = nil
end

function UIManageRolePanel:_on_init()
    log_debug("UIManageRolePanel:init")
    UIManageRolePanel.super._on_init(self)

end

function UIManageRolePanel:_on_attach_panel()
    UIManageRolePanel.super._on_attach_panel(self)
    self._notify_txt = UIHelp.attach_ui(UIText, self._panel_root, "notify_txt")


    self._gate_state_txt = UIHelp.attach_ui(UIText, self._panel_root, "gate_view/cnn_state")
    self._gate_cnn_btn = UIHelp.attach_ui(UIButton, self._panel_root, "gate_view/cnn_btn")
    self._gate_cnn_btn:set_onclick(Functional.make_closure(self._on_click_gate_cnn_btn, self))
    self._re_login_btn = UIHelp.attach_ui(UIButton, self._panel_root, "gate_view/relogin_btn")
    self._re_login_btn:set_onclick(Functional.make_closure(self._on_click_re_login_btn, self))

    self._role_list_content_ts = UIHelp.find_transform(self._panel_root, "role_view/role_list/scroll_view/Viewport/Content")
    self._role_list_content_item_prefab = UIHelp.find_gameobject(self._panel_root, "role_view/role_list/scroll_view/Viewport/Content/item")
    UIHelp.set_active(self._role_list_content_item_prefab, false)

    self._create_role_btn = UIHelp.attach_ui(UIButton, self._panel_root, "role_view/opera_btns/create_role_btn")
    self._create_role_btn:set_onclick(Functional.make_closure(self._on_click_create_role_btn, self))
    self._launch_role_btn = UIHelp.attach_ui(UIButton, self._panel_root, "role_view/opera_btns/launch_role_btn")
    self._launch_role_btn:set_onclick(Functional.make_closure(self._on_click_launch_role_btn, self))

    self._role_detail_role_id_txt = UIHelp.attach_ui(UIText, self._panel_root, "role_view/role_detail/role_id/content")

    self._event_binder:bind(self._app.net_mgr, Game_Net_Event.gate_connect_done, Functional.make_closure(self._update_gate_state_txt, self))
    self._event_binder:bind(self._app.net_mgr, Game_Net_Event.gate_connect_ready_change, Functional.make_closure(self._update_gate_state_txt, self))
    self._event_binder:bind(self._app.data_mgr.game_user, Game_User_Event.role_digiests_change, Functional.make_closure(self._update_role_digiests, self))
    self._event_binder:bind(self._app.data_mgr.game_user, Game_User_Event.role_reachable_change, Functional.make_closure(self._on_event_role_reachable_change, self))

    self:_update_ui()
end

function UIManageRolePanel:_on_open(panel_data)
    UIManageRolePanel.super._on_open(self, panel_data)

    -- log_info("UIManageRolePanel:on_show")
end

function UIManageRolePanel:_on_enable()
    UIManageRolePanel.super._on_enable(self)
    -- log_info("UIManageRolePanel:_on_enable")
    -- self.ml_event_subscriber:release_all()
end

function UIManageRolePanel:_on_disable()
    UIManageRolePanel.super._on_disable(self)
    -- log_info("UIManageRolePanel:_on_disable")
    -- self.ml_event_subscriber:release_all()
end

function UIManageRolePanel:_on_release()
    UIManageRolePanel.super._on_release(self)
    -- log_info("UIManageRolePanel:on_release")
    -- self.ml_event_subscriber:release_all()
end

function UIManageRolePanel:_on_click_role_list_item(item_data)

end

function UIManageRolePanel:_on_click_gate_cnn_btn()
    if not self._gate_net:is_ready() then

    end

    self._gate_net:disconnect()
    self._gate_net:connect()
end

function UIManageRolePanel:_on_click_re_login_btn()
    self._platform_net:logout()
    self._login_net:logout()
    self._gate_net:disconnect()
    self._app.state_mgr:change_state(App_State_Name.login)
end

function UIManageRolePanel:_on_click_create_role_btn()
    if self._gate_net:is_ready() then
        self._app.data_mgr.game_user:create_role("")
    else
        self:_notify_error("is not ready to create role")
    end
end

function UIManageRolePanel:_on_click_launch_role_btn()
    if self._gate_net:is_ready() and self._selected_role_id then
        self._app.data_mgr.game_user:launch_role(self._selected_role_id)
    else
        self:_notify_error("is not ready to launch role")
    end
end

function UIManageRolePanel:_notify_error(error_msg)
    self._notify_txt:set_text(error_msg)
end

function UIManageRolePanel:_update_ui()
    self:_update_gate_state_txt()
    self:_update_role_digiests()
end

function UIManageRolePanel:_update_gate_state_txt()
    local ret_txt = ""
    if self._gate_net:is_ready() then
        ret_txt = "is_ready"
    else
        if self._gate_net:is_connecting() then
            ret_txt = "connecting"
        else
            ret_txt = string.format("not ready, error msg is %s", self._gate_net:get_error_msg())
        end
    end
    self._gate_state_txt:set_text(ret_txt)
end

function UIManageRolePanel:_update_role_digiests()
    for _, v in pairs(self._role_list_items) do
        UIHelp.destroy_gameobject(v.go)
    end
    self._role_list_items = {}
    local role_digiests = self._app.data_mgr.game_user:get_role_digests()
    if role_digiests then
        for role_id, role_digiest in pairs(role_digiests) do
            local curr_role_id = role_id
            local go = UIHelp.clone_gameobject(self._role_list_content_item_prefab)
            UIHelp.set_parent(go, self._role_list_content_ts)
            UIHelp.attach_ui(UIText, go,"role_name"):set_text(role_id)
            UIHelp.attach_ui(UIButton, go, ""):set_onclick(function()
                log_print("self._selected_role_id = ", self._selected_role_id)
                self._selected_role_id = curr_role_id
            end)
            table.insert(self._role_list_items, {
                role_id = role_id,
                go = go,
            })
        end
    end
end

function UIManageRolePanel:_on_event_role_reachable_change(is_role_reachable)
    if is_role_reachable then
    end
end





