Panel_State = {
    free = "free",
    disable = "disable",
    enable = "enable",
    released = "Released",
}

Panel_Layer = {
    coexist_0 = "coexist_0",
    coexist_1 = "coexist_1",
    coexist_2 = "coexist_2",
    mask = "mask",
    full_screen = "full_screen",
    upon_full_screen = "upon_full_screen",
    loading = "loading",
}

Panel_Layer_Setting = {
    [Panel_Layer.coexist_0] = {
        name = Panel_Layer.coexist_0,
        relative_path = "UILayer/Coexist_0",
    },
    [Panel_Layer.coexist_1] = {
        name = Panel_Layer.coexist_1,
        relative_path = "UILayer/Coexist_1",
    },
    [Panel_Layer.coexist_2] = {
        name = Panel_Layer.coexist_2,
        relative_path = "UILayer/Coexist_2",
    },
    [Panel_Layer.mask] = {
        name = Panel_Layer.mask,
        relative_path = "UILayer/Mask",
    },
    [Panel_Layer.full_screen] = {
        name = Panel_Layer.full_screen,
        relative_path = "UILayer/FullScreen",
    },
    [Panel_Layer.upon_full_screen] = {
        name = Panel_Layer.upon_full_screen,
        relative_path = "UILayer/UponFullScreen",
    },
    [Panel_Layer.loading] = {
        name = Panel_Layer.loading,
        relative_path = "UILayer/Loading",
    },
}

--[[
UI_Panel_Show_Mode = {
    coexist = "coexist", -- 共存
    mask = "mask", -- 遮挡下层panel
    hide_other = "hide_other", -- 遮挡其他， 这里同时只存在一个全屏panel，若是新show一个全屏panel，新的顶替旧的
    upon_hide_other = "upon_hide_other", -- 在隐藏其他模式的面板之上
    loading = "loading", -- 加载面板层，在最上边遮挡所有UI
}
]]


