
Item = Item or class("Item")

function Item:ctor()
    self.item_id = gen_next_seq()
end

function Item:say_hi()
    -- print(string.format("Item which Item id = %s, say hi to you", self.item_id))
end

print("reach Item ")
return Item