
ItemMgr = ItemMgr or class("ItemMgr")

function ItemMgr:ctor()
    self._items = {}
end

function ItemMgr:add_item(item)
    self._items[item.item_id] = item
end

function ItemMgr:remove_item(item_id)
    self._items[item_id] = nil
end

function ItemMgr:tick_item()
    for _, v in pairs(self._items) do
        v:say_hi()
    end
    -- print("ItemMgr:tick_item")
end
