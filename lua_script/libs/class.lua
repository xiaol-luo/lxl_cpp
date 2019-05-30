local setmetatableindex_
setmetatableindex_ = function(t, index)
    local mt = getmetatable(t)
    if not mt then mt = {} end
    if not mt.__index then
        mt.__index = index
        setmetatable(t, mt)
    elseif mt.__index ~= index then
        setmetatableindex_(mt, index)
    end
end
setmetatableindex = setmetatableindex_

local tRegisterClass = {}

function class(class_name, super)
    assert(not tRegisterClass[class_name], string.format("class() - has created class \"%s\" ", class_name))
    tRegisterClass[class_name] = true

    local super_type = type(super)
    assert("nil" == super_type or "table" == super_type,
            string.format("class() - create class \"%s\" with invalid super class type \"%s\"", class_name, super_type))

    local cls = { __cname = class_name }
    cls.super = super
    cls.__index = cls
    setmetatable(cls, { __index = cls.super })

    if not cls.ctor then
        cls.ctor = function() end
    end

    cls.new = function(_, ...)
        local instance
        if cls.__create then
            instance = cls.__create(...)
        else
            instance = {}
        end
        setmetatableindex(instance, cls)
        instance._class_type = cls
        instance:ctor(...)
        return instance
    end

    return cls
end