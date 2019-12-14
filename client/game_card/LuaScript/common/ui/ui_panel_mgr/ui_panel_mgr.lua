
UIPanelMgr = UIPanelMgr or class("UIPanelMgr")

UIPanelMgr.Const = UIPanelMgr.Const or {
    Preload_Res_List = {
        Panel_Wrapper_Prefab_Path = "Assets/Res/UI/PanelMgr/UIPanelProxy.prefab",
    }
}

function UIPanelMgr:ctor()
    self.res_loader = nil
    self.event_mgr = nil
    self.timer_proxy = nil
    self.root_go = nil
    self.already_prepare_assets = false
    self.panel_wrapper_map = {}
    self.panel_wrapper_res_obs = nil
end

function UIPanelMgr:init(root_go_path)
    self.res_loader = CS.Lua.LuaResLoaderProxy.Create()
    self.event_mgr = EventMgr:new()
    self.timer_proxy = TimerProxy:new()
    self.root_go = CS.UnityEngine.GameObject.Find(root_go_path)
    assert(root_go)
end

function UIPanelMgr:prepare_assets()
    if self.already_prepare_assets then
        return
    end
    self.already_prepare_assets = true
    for _, v in pairs(UIPanelMgr.Const.Preload_Res_List) do
        local res_obs = self.res_loader:LoadAsset(v)
        if v == UIPanelMgr.Const.Preload_Res_List.Panel_Wrapper_Prefab_Path then
            self.panel_wrapper_res_obs = res_obs
        end
    end
end

function UIPanelMgr:show_panel(panel_name, panel_data)

end

function UIPanelMgr:reshow_panel(panel_name)

end

function UIPanelMgr:hide_panel(panel_name)

end

function UIPanelMgr:hide_all_panel(panel_name)

end

function UIPanelMgr:release_panel(panel_name)

end

function UIPanelMgr:release_all_panel()
end

function UIPanelMgr:get_topest_active_panel_name()

end

function UIPanelMgr:release_self()
    self.res_loader:Release()
    self.event_mgr:cancel_all()
    self.timer_proxy:release_all()
end










