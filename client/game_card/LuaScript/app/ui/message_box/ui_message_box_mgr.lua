
---@class UIMessageBoxMgr
---@field ui_mgr UIMgr
---@field panel_mgr UIPanelMgr
UIMessageBoxMgr = UIMessageBoxMgr or class("UIMessageBoxMgr")

function UIMessageBoxMgr:ctor(ui_mgr)
    self.ui_mgr = ui_mgr
    self.panel_mgr = ui_mgr.panel_mgr
    self._msg_box_data_head = nil
    self._msg_box_data_tail = nil
    self._next_id = 0
    ---@type UIMessageDataWrap
    self._wrap_data = nil
end

function UIMessageBoxMgr:init()
    self._data_wrap = UIMessageDataWrap:new()
    self._data_wrap.confirm_cb = Functional.make_closure(self._on_click_confirm, self)
    self._data_wrap.cancel_cb = Functional.make_closure(self._on_click_cancel, self)
    self._on_click_close = Functional.make_closure(self._on_click_close, self)
end

function UIMessageBoxMgr:release()
    self._msg_box_data_head = nil
    self._msg_box_data_tail = nil
    self._wrap_data = nil
end

---@param msg_box_data UIMessageData
function UIMessageBoxMgr:add_msg_box(msg_box_data)
    if msg_box_data.unique_id then
        self:remove_msg_box(msg_box_data.unique_id)
    end
    msg_box_data.unique_id = self:_gen_id()
    local node = {
        data = msg_box_data,
        next_ptr = nil
    }
    if not self._msg_box_data_head then
        self._msg_box_data_head = node
        self._msg_box_data_tail = node
    else
        self._msg_box_data_tail.next_ptr = node
        self._msg_box_data_tail = node
    end

    self:_check_show_msg_box()
end

function UIMessageBoxMgr:remove_msg_box(unique_id)
    if not self._msg_box_data_head then
        return nil
    end
    local cmp_node = self._msg_box_data_head
    if cmp_node.unique_id == unique_id then
        self._msg_box_data_head = cmp_node.next_ptr
        cmp_node.next_ptr = nil
        cmp_node.unique_id = nil
        if self._msg_box_data_tail == cmp_node then
            self._msg_box_data_tail = nil
        end
        return cmp_node
    end

    local pre_ptr = cmp_node
    cmp_node = pre_ptr.next_ptr
    repeat
        if not cmp_node then
            break
        end
        if cmp_node.unique_id == unique_id then
            break
        end
        pre_ptr = cmp_node
        cmp_node = cmp_node.next_ptr
    until false
    if cmp_node then
        pre_ptr.next_ptr = cmp_node.next_ptr
        cmp_node.next_ptr = nil
        cmp_node.unique_id = nil
        if self._msg_box_data_tail == cmp_node then
            self._msg_box_data_tail = nil
        end
    end
    return cmp_node.data
end

function UIMessageBoxMgr:_check_show_msg_box()
    if self._data_wrap.msg_data then
        return
    end
    if not self._msg_box_data_head then
        return
    end
    local data = self._msg_box_data_head.data
    self:remove_msg_box(data.unique_id)
    self._data_wrap.msg_data = data
    -- show 面板
end

function UIMessageBoxMgr:_close_msg_box()
    self._data_wrap.msg_data = nil
    -- 关闭面板
end

function UIMessageBoxMgr:_on_click_confirm()
    if self._data_wrap.msg_data and self._data_wrap.msg_data.confirm_cb then
        self._data_wrap.msg_data.confirm_cb()
    end
end

function UIMessageBoxMgr:_on_click_cancel()
    if self._data_wrap.msg_data and self._data_wrap.msg_data.cancel_cb then
        self._data_wrap.msg_data.cancel_cb()
    end
end

function UIMessageBoxMgr:_on_click_close()
    if self._data_wrap.msg_data and self._data_wrap.msg_data.close_cb then
        self._data_wrap.msg_data.close_cb()
    end
end

function UIMessageBoxMgr:_gen_id()
    self._next_id = self._next_id + 1
    return self._next_id
end


