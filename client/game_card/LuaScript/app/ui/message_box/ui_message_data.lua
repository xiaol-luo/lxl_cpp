
---@class MessageBoxViewType
MessageBoxViewType = {}
MessageBoxViewType.confirm = "confirm"
MessageBoxViewType.refuse_confirm = "refuse_confirm"
MessageBoxViewType.ignore_confirm = "ignore_confirm"
MessageBoxViewType.refuse_ignore_confirm = "refuse_ignore_confirm"


---@class UIMessageBoxData
---@field unique_id number
---@field view_type MessageBoxViewType
---@field cb_confirm fun():void
---@field cb_refuse fun():void
---@field cb_ignore fun():void
---@field str_title string
---@field str_content string
---@field str_confirm string
---@field str_refuse string
---@field str_ignore string
UIMessageBoxData = UIMessageBoxData or class("UIMessageBoxData")

function UIMessageBoxData:ctor()
    self.unique_id = nil
    self.view_type = MessageBoxViewType.confirm
    self.cb_confirm = nil
    self.cb_refuse = nil
    self.cb_ignore = nil
    self.str_title = "notice"
    self.str_content = ""
    self.str_confirm = "confirm"
    self.str_refuse = "refuse"
    self.str_ignore = ""
end

---@class UIMessageBoxDataWrap
---@field data UIMessageBoxData
---@field cb_confirm fun():void
---@field cb_refuse fun():void
---@field cb_ignore fun():void
UIMessageBoxDataWrap = UIMessageBoxDataWrap or class("UIMessageBoxDataWrap")

function UIMessageBoxDataWrap:ctor()
    self.data = nil
    self.cb_confirm = nil
    self.cb_refuse = nil
    self.cb_ignore = nil
end


---@class UIMessageBoxDataQueueElem
---@field next_ptr UIMessageBoxData
---@field data UIMessageBoxData

