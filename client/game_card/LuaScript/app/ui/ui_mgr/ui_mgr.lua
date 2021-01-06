
---@class UIMgr
---@field panel_mgr UIPanelMgr
---@field msg_box UIMessageBoxMgr
---@field tips UITipsMgr
UIMgr = UIMgr or class("UIMgr")

function UIMgr:ctor(panel_mgr)
    self.panel_mgr = panel_mgr
    self.msg_box = nil
    self.tips = nil
end

function UIMgr:init()
    self.msg_box = UIMessageBoxMgr:new(self)
    self.msg_box:init()

    self.tips = UITipsMgr:new(self)
    self.tips:init()
end

function UIMgr:release()
    self.msg_box:release()
    self.tips:release()
end



