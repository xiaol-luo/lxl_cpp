
UI_Panel_Name = {
    main_panel = "main_panel",
    loading_panel = "loading_panel",
    confirm_panel = "confirm_panel",
    login_panel = "login_panel",
    launch_role_panel = "launch_role_panel",
}

UI_Panel_Setting = {
    [UI_Panel_Name.main_panel]= {
        belong_layer = Panel_Layer.coexist_0,
        res_path = "Assets/Res/UI/PanelMgr/MainPanel/MainPanel.prefab",
        panel_cls = UIMainPanel,
    },

    [UI_Panel_Name.loading_panel]= {
        belong_layer = Panel_Layer.loading,
        res_path = "Assets/Res/UI/PanelMgr/MainPanel/MainPanel.prefab",
        panel_cls = UIMainPanel,
    },
    [UI_Panel_Name.confirm_panel]= {
        belong_layer = Panel_Layer.mask,
        res_path = "Assets/Res/UI/PanelMgr/MainPanel/MainPanel.prefab",
        panel_cls = UIMainPanel,
    },
    [UI_Panel_Name.login_panel]= {
        belong_layer = Panel_Layer.coexist_0,
        res_path = "Assets/Res/UI/PanelMgr/LoginPanel/LoginPanel.prefab",
        panel_cls = UILoginPanel,
    },
    [UI_Panel_Name.launch_role_panel] = {
        belong_layer = Panel_Layer.coexist_0,
        res_path = "Assets/Res/UI/PanelMgr/LaunchRolePanel/LaunchRolePanel.prefab",
        panel_cls = UILaunchRolePanel,
    }
}

for panel_name, panel_setting in pairs(UI_Panel_Setting) do
    panel_setting.panel_name = panel_name
end



