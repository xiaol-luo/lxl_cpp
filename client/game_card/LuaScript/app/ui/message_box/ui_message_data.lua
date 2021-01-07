
---@class MessageBoxViewType
MessageBoxViewType = {}
MessageBoxViewType.confirm = "confirm"
MessageBoxViewType.cancel_confirm = "cancel_confirm"


---@class UIMessageData
---@field unique_id number
---@field view_type MessageBoxViewType
---@field confirm_cb fun():void
---@field cancel_cb fun():void
---@field close_cb fun():void
---@field str_content string
---@field str_confirm string
---@field str_cancel string
UIMessageData = UIMessageData or class("UIMessageData")

function UIMessageData:ctor()
    self.unique_id = nil
    self.view_type = MessageBoxViewType.confirm
    self.confirm_cb = nil
    self.cancel_cb = nil
    self.close_cb = nil
    self.str_content = ""
    self.str_confirm = "confirm"
    self.str_cancel = "cancel"
end

---@class UIMessageDataWrap
---@field data UIMessageData
---@field confirm_cb fun():void
---@field cancel_cb fun():void
---@field close_cb fun():void
UIMessageDataWrap = UIMessageDataWrap or class("UIMessageDataWrap")

function UIMessageDataWrap:ctor()
    self.data = nil
    self.confirm_cb = nil
    self.cancel_cb = nil
    self.close_cb = nil
end


---@class UIMessageDataQueueElem
---@field next_ptr UIMessageData
---@field data UIMessageData

