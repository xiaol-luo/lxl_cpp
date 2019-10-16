-- main.lua

require("item")

local item = Item.new("item created before hotfix")
item:print_self()

hotfix_file("item_for_hotfix")
print("Hitfix Done!")
item:print_self()

local item_after_hotif = Item.new("item created after hotfix")
item_after_hotif:print_self()
