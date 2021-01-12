
---@class UIMessageBoxMgr
---@field ui_mgr UIMgr
---@field panel_mgr UIPanelMgr
UIMessageBoxMgr = UIMessageBoxMgr or class("UIMessageBoxMgr")

function UIMessageBoxMgr:ctor(ui_mgr)
    self.ui_mgr = ui_mgr
    self.panel_mgr = ui_mgr.panel_mgr
    ---@type UIMessageBoxDataQueueElem
    self._msg_box_data_head = nil
    ---@type UIMessageBoxDataQueueElem
    self._msg_box_data_tail = nil
    self._next_id = 0
    ---@type UIMessageBoxDataWrap
    self._wrap_data = nil
end

function UIMessageBoxMgr:init()
    self._data_wrap = UIMessageBoxDataWrap:new()
    self._data_wrap.cb_confirm = Functional.make_closure(self._on_click_confirm, self)
    self._data_wrap.cb_refuse = Functional.make_closure(self._on_click_refuse, self)
    self._data_wrap.cb_ignore = Functional.make_closure(self._on_click_ignore, self)
end

function UIMessageBoxMgr:release()
    self._msg_box_data_head = nil
    self._msg_box_data_tail = nil
    self._wrap_data = nil
    self:_close_msg_box()
end

---@param msg_box_data UIMessageBoxData
function UIMessageBoxMgr:add_msg_box(msg_box_data)
    if msg_box_data.unique_id then
        self:remove_msg_box(msg_box_data.unique_id)
    end
    msg_box_data.unique_id = self:_gen_id()
    ---@type UIMessageBoxDataQueueElem
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
    return msg_box_data.unique_id
end

function UIMessageBoxMgr:remove_msg_box(unique_id)
    if not self._msg_box_data_head then
        return nil
    end
    local cmp_node = self._msg_box_data_head
    if cmp_node.data.unique_id == unique_id then
        self._msg_box_data_head = cmp_node.next_ptr
        cmp_node.next_ptr = nil
        cmp_node.data.unique_id = nil
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
        if cmp_node.data.unique_id == unique_id then
            break
        end
        pre_ptr = cmp_node
        cmp_node = cmp_node.next_ptr
    until false
    if cmp_node then
        pre_ptr.next_ptr = cmp_node.next_ptr
        cmp_node.next_ptr = nil
        cmp_node.data.unique_id = nil
        if self._msg_box_data_tail == cmp_node then
            self._msg_box_data_tail = pre_ptr
        end
    end
    return cmp_node and cmp_node.data or nil
end

function UIMessageBoxMgr:_check_show_msg_box()
    if self._data_wrap.data then
        return
    end
    if not self._msg_box_data_head then
        return
    end
    local data = self._msg_box_data_head.data
    self:remove_msg_box(data.unique_id)
    self._data_wrap.data = data
    -- show 面板
    self.panel_mgr:open_panel(UI_Panel_Name.message_box, self._data_wrap)
end

function UIMessageBoxMgr:_close_msg_box()
    self._data_wrap.data = nil
    -- 关闭面板
    self.panel_mgr:close_panel(UI_Panel_Name.message_box, true)
    self:_check_show_msg_box()
end

function UIMessageBoxMgr:_on_click_confirm()
    if self._data_wrap.data and self._data_wrap.data.cb_confirm then
        self._data_wrap.data.cb_confirm()
    end
    self:_close_msg_box()
end

function UIMessageBoxMgr:_on_click_refuse()
    if self._data_wrap.data and self._data_wrap.data.cb_refuse then
        self._data_wrap.data.cb_refuse()
    end
    self:_close_msg_box()
end

function UIMessageBoxMgr:_on_click_ignore()
    if self._data_wrap.data and self._data_wrap.data.cb_ignore then
        self._data_wrap.data.cb_ignore()
    end
    self:_close_msg_box()
end

function UIMessageBoxMgr:_gen_id()
    self._next_id = self._next_id + 1
    return self._next_id
end


function UIMessageBoxMgr:show_confirm(str_content, str_confirm, cb_confirm)
    local msg_box_data = UIMessageBoxData:new()
    msg_box_data.view_type = MessageBoxViewType.refuse_confirm
    msg_box_data.str_content = str_content or msg_box_data.str_content
    msg_box_data.str_confirm = str_confirm or msg_box_data.str_confirm
    msg_box_data.cb_confirm = cb_confirm or msg_box_data.cb_confirm
    return self:add_msg_box(msg_box_data)
end

function UIMessageBoxMgr:show_confirm_refuse(str_content, str_confirm, cb_confirm, str_refuse, cb_refuse)
    local msg_box_data = UIMessageBoxData:new()
    msg_box_data.view_type = MessageBoxViewType.refuse_confirm
    msg_box_data.str_content = str_content or msg_box_data.str_content
    msg_box_data.str_confirm = str_confirm or msg_box_data.str_confirm
    msg_box_data.cb_confirm = cb_confirm or msg_box_data.cb_confirm
    msg_box_data.str_refuse = str_refuse or msg_box_data.str_refuse
    msg_box_data.cb_refuse = cb_refuse or msg_box_data.cb_refuse
    return self:add_msg_box(msg_box_data)
end

function UIMessageBoxMgr:show_confirm_refuse_ignore(str_content, str_confirm, cb_confirm, str_refuse, cb_refuse, str_ignore, cb_ignore)
    local msg_box_data = UIMessageBoxData:new()
    msg_box_data.view_type = MessageBoxViewType.refuse_ignore_confirm
    msg_box_data.str_content = str_content or msg_box_data.str_content
    msg_box_data.str_confirm = str_confirm or msg_box_data.str_confirm
    msg_box_data.cb_confirm = cb_confirm or msg_box_data.cb_confirm
    msg_box_data.str_refuse = str_refuse or msg_box_data.str_refuse
    msg_box_data.cb_refuse = cb_refuse or msg_box_data.cb_refuse
    msg_box_data.str_ignore = str_ignore or msg_box_data.str_ignore
    msg_box_data.cb_ignore = cb_ignore or msg_box_data.cb_ignore
    return self:add_msg_box(msg_box_data)
end

function UIMessageBoxMgr:show_confirm_with_title(str_title, str_content, str_confirm, cb_confirm)
    local msg_box_data = UIMessageBoxData:new()
    msg_box_data.view_type = MessageBoxViewType.refuse_confirm
    msg_box_data.str_title = str_title or msg_box_data.str_title
    msg_box_data.str_content = str_content or msg_box_data.str_content
    msg_box_data.str_confirm = str_confirm or msg_box_data.str_confirm
    msg_box_data.cb_confirm = cb_confirm or msg_box_data.cb_confirm
    return self:add_msg_box(msg_box_data)
end

function UIMessageBoxMgr:show_confirm_refuse_with_title(str_title, str_content, str_confirm, cb_confirm, str_refuse, cb_refuse)
    local msg_box_data = UIMessageBoxData:new()
    msg_box_data.view_type = MessageBoxViewType.refuse_confirm
    msg_box_data.str_title = str_title or msg_box_data.str_title
    msg_box_data.str_content = str_content or msg_box_data.str_content
    msg_box_data.str_confirm = str_confirm or msg_box_data.str_confirm
    msg_box_data.cb_confirm = cb_confirm or msg_box_data.cb_confirm
    msg_box_data.str_refuse = str_refuse or msg_box_data.str_refuse
    msg_box_data.cb_refuse = cb_refuse or msg_box_data.cb_refuse
    return self:add_msg_box(msg_box_data)
end

function UIMessageBoxMgr:show_confirm_refuse_ignore_with_title(str_title, str_content, str_confirm, cb_confirm, str_refuse, cb_refuse, str_ignore, cb_ignore)
    local msg_box_data = UIMessageBoxData:new()
    msg_box_data.view_type = MessageBoxViewType.refuse_ignore_confirm
    msg_box_data.str_title = str_title or msg_box_data.str_title
    msg_box_data.str_content = str_content or msg_box_data.str_content
    msg_box_data.str_confirm = str_confirm or msg_box_data.str_confirm
    msg_box_data.cb_confirm = cb_confirm or msg_box_data.cb_confirm
    msg_box_data.str_refuse = str_refuse or msg_box_data.str_refuse
    msg_box_data.cb_refuse = cb_refuse or msg_box_data.cb_refuse
    msg_box_data.str_ignore = str_ignore or msg_box_data.str_ignore
    msg_box_data.cb_ignore = cb_ignore or msg_box_data.cb_ignore
    return self:add_msg_box(msg_box_data)
end


