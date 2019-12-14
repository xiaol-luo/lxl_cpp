UI_Panel_Setting_Help = UI_Panel_Setting_Help or {}

function UI_Panel_Setting_Help.adjust_setting()
    for k, v in pairs(UI_Panel_Setting) do
        do -- 调整show_mode和layer的关系 某些show_mode下，layer有强制归属
            local expect_layer, old_layer, need_warn = UI_Panel_Setting.cal_belong_layer_by_show_mode(v.show_mode, v.belong_layer)
            if need_warn then
                log_warn("ui_panel_setting show_mode and belong layer mismatch, panel_name=%s, panel_mode=%s, belong_layer=%s, expect_belong_layer=%s",
                        k, v.panel_mode, v.belong_layer, expect_layer)
            end
            assert(expect_layer)
            v.belong_layer = expect_layer
        end
    end
end

function UI_Panel_Setting_Help.cal_belong_layer_by_show_mode(show_mode, belong_layer)
    assert(show_mode)
    local ret_belong_layer = nil
    local need_warn = false
    if UI_Panel_Show_Mode.loading == show_mode then
        ret_belong_layer = UI_Panel_Layer.loading
    end
    if UI_Panel_Show_Mode.upon_hide_other == show_mode then
        ret_belong_layer = UI_Panel_Layer.upon_full_screen
    end
    if UI_Panel_Show_Mode.hide_other == show_mode then
        ret_belong_layer = UI_Panel_Layer.full_screen
    end
    if UI_Panel_Show_Mode.mask == show_mode then
        ret_belong_layer = UI_Panel_Layer.mask
    end
    if UI_Panel_Show_Mode.coexist == show_mode then
        if nil == belong_layer then
            ret_belong_layer = UI_Panel_Layer.coexist_0
            need_warn = true
        else
            if UI_Panel_Layer.coexist_0 ~= belong_layer
                    and UI_Panel_Layer.coexist_1 ~= belong_layer
                    and UI_Panel_Layer.coexist_2 ~= belong_layer
            then
                ret_belong_layer = UI_Panel_Layer.coexist_0
                need_warn = true
            else
                ret_belong_layer = belong_layer
            end
        end
    end
    if nil == ret_belong_layer then
        need_warn = true
    end
    if nil ~= belong_layer and ret_belong_layer ~= belong_layer then
        need_warn = true
    end
    return ret_belong_layer, belong_layer, need_warn
end


UI_Panel_Name = {
    main_panel = "main_panel",
    loading_panel = "loading_panel",
    confirm_panel = "confirm_panel",
}

UI_Panel_Setting = {
    [UI_Panel_Name.main_panel]= {
        belong_layer = UI_Panel_Layer.coexist_0,
        show_mode = UI_Panel_Show_Mode.coexist,
        res_path = "Assets/Res/UI/PanelMgr/MainPanel/MainPanel.prefab",
    },

    [UI_Panel_Name.loading_panel]= {
        belong_layer = UI_Panel_Layer.loading,
        show_mode = UI_Panel_Show_Mode.loading,
        res_path = "Assets/Res/UI/PanelMgr/MainPanel/MainPanel.prefab",
    },
    [UI_Panel_Name.confirm_panel]= {
    belong_layer = UI_Panel_Layer.mask,
    show_mode = UI_Panel_Show_Mode.mask,
    res_path = "Assets/Res/UI/PanelMgr/MainPanel/MainPanel.prefab",
},
}



