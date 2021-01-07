
---@class UITipsMgr
---@field ui_mgr UIMgr
---@field panel_mgr UIPanelMgr
UITipsMgr = UITipsMgr or class("UITipsMgr")

function UITipsMgr:ctor(ui_mgr)
    self.ui_mgr = ui_mgr
    self.panel_mgr = ui_mgr.panel_mgr
    ---@type UITipsDataQueueElem
    self._tips_data_head = nil
    ---@type UITipsDataQueueElem
    self._tips_data_tail = nil
    ---@type UITipsDataWrap
    self._wrap_data = UITipsDataWrap:new()
    ---@type TimerProxy
    self._timer_proxy = TimerProxy:new()
    self._update_tid = nil

    self.Tips_Show_MS = 2000
end

function UITipsMgr:init()

end

function UITipsMgr:release()
    self._tips_data_head = nil
    self._tips_data_tail = nil
    self._wrap_data = nil
    self._timer_proxy:release_all()
end

---@param tips_data UITipsData
function UITipsMgr:enqueue_tips(tips_data)
    ---@type UITipsDataQueueElem
    local node = {
        data = tips_data,
        next_ptr = nil
    }
    if self._tips_data_tail then
        self._tips_data_tail.next_ptr = node
        self._tips_data_tail = node
    else
        self._tips_data_tail = node
        self._tips_data_head = node
    end
    self:_check_show_tips()
end

---@return @UITipsData
function UITipsMgr:dequeue_tips()
    ---@type UITipsDataQueueElem
    local ret = nil
    if self._tips_data_head then
        ret = self._tips_data_head
        self._tips_data_head = self._tips_data_head.next_ptr
        if ret == self._tips_data_tail then
            self._tips_data_tail = nil
        end
    end
    return ret and ret.data or nil
end

function UITipsMgr:_check_show_tips()
    if self._wrap_data.data then
        return
    end

    local data = self:dequeue_tips()
    if not data then
        if self._update_tid then
            self._timer_proxy:remove(self._update_tid)
            self._update_tid = nil
        end
        self.panel_mgr:close_panel(UI_Panel_Name.tips_panel, true)
    else
        self._wrap_data.data = data
        self._wrap_data.show_end_ms = logic_ms() + self.Tips_Show_MS
        self.panel_mgr:open_panel(UI_Panel_Name.tips_panel, self._wrap_data)
        -- show panel
        if not self._update_tid then
            self._update_tid = self._timer_proxy:firm(Functional.make_closure(self._on_update, self),
                    0.3, Forever_Execute_Timer)
        end
    end
end

function UITipsMgr:_on_update()
    local now_ms = logic_ms()
    if now_ms >= self._wrap_data.show_end_ms then
        self._wrap_data.data = nil
        self:_check_show_tips()
    end
end







