--[[
    这个实现只支持一层json序列化和反序列化
]]

local rapidjson = require('rapidjson')

---@class JsonData
JsonData = JsonData or class("JsonData")

function JsonData:ctor(fields)
    self._fields = fields
    for k, v in pairs(self._fields) do
        assert(is_string(v) and v ~= "_fields", string.format("JsonData:ctor fields[%s]=%s, contain _fields is not allow", k, v))
    end
end

function JsonData:to_json()
    local tb = {}
    for k, v in pairs(self._fields) do
        tb[v] = self[v]
    end
    local ret = rapidjson.encode(tb)
    return ret
end

function JsonData.from_json(json_str)
    local ret = JsonData:new(nil, nil, nil, nil)
    local tb = rapidjson.decode(json_str)
    for _, v in pairs(self._fields) do
        ret[v] = tb[v]
    end
    return ret
end
