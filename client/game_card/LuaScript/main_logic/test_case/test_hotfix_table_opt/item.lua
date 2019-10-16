-- item.lua

Item = Item or {}

g_price = 1

g_fn = function()
    return "reach old g_fn"
end

local upvalue_var = "old_upvalue_var"

local upvalue_fn = function()
    return "reach old upvalue_fn"
end

function Item.new(tag)
    local t = {}
    setmetatable(t, {__index=Item})
    t.tag = tag
    t.g_price = g_price
    t.g_fn = g_fn
    t.upvalue_var = upvalue_var
    t.upvalue_fn = upvalue_fn
    return t
end

function Item:print_self()
    print(string.format("Old Item:print_self, self.tag = %s, self.g_price = %s, self.g_fn()=%s, self.upvalue_var = %s, self.upvalue_fn()=%s",
            self.tag, self.g_price, self.g_fn(), self.upvalue_var, self.upvalue_fn()))
end

