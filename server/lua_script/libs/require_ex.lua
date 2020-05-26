
function batch_require(...)
    for _, v in pairs(...) do
        local tp = type(v)
        if "table" == tp then
            batch_require(table.unpack(v))
        end
        if "string" == tp then
            require(v)
        end
    end
end