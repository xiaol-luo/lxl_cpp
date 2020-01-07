
UI_Panel_Name = {
    main_panel = "main_panel",
    loading_panel = "loading_panel",
    confirm_panel = "confirm_panel",
    login_panel = "login_panel",
}

UI_Panel_Setting = {
    [UI_Panel_Name.main_panel]= {
        belong_layer = UI_Panel_Layer.coexist_0,
        show_mode = UI_Panel_Show_Mode.coexist,
        res_path = "Assets/Res/UI/PanelMgr/MainPanel/MainPanel.prefab",
        panel_logic = UIMainPanel,
    },

    [UI_Panel_Name.loading_panel]= {
        belong_layer = UI_Panel_Layer.loading,
        show_mode = UI_Panel_Show_Mode.loading,
        res_path = "Assets/Res/UI/PanelMgr/MainPanel/MainPanel.prefab",
        panel_logic = UIMainPanel,
    },
    [UI_Panel_Name.confirm_panel]= {
        belong_layer = UI_Panel_Layer.mask,
        show_mode = UI_Panel_Show_Mode.mask,
        res_path = "Assets/Res/UI/PanelMgr/MainPanel/MainPanel.prefab",
        panel_logic = UIMainPanel,
    },
    [UI_Panel_Name.login_panel]= {
        belong_layer = UI_Panel_Layer.coexist_0,
        show_mode = UI_Panel_Show_Mode.coexist,
        res_path = "Assets/Res/UI/PanelMgr/LoginPanel/LoginPanel.prefab",
        panel_logic = UILoginPanel,
    },

}



