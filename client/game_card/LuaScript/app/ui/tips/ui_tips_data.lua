
---@class UITipsData
---@field str_content string
UITipsData = UITipsData or class("UITipsData")

function UITipsData:ctor()
    self.str_content = nil
end

---@class UITipsDataQueueElem
---@field next_ptr UITipsData
---@field data UITipsData

---@class UITipsDataWrap
UITipsDataWrap = UITipsDataWrap or class("UITipsDataWrap")

function UITipsDataWrap:ctor()
    self.show_end_ms = 0
    self.data = nil
end

