
local old_print = print

function print(...)
    local str_list = {}
    for _, arg in pairs({...}) do
        if "table" ~= type(arg) then
            table.insert(str_list, tostring(arg))

        else
            table.insert(str_list, string.toprint(arg))
        end
    end
    old_print(table.concat(str_list, ' '))
end