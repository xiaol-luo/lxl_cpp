local setmetatable_help_
setmetatable_help_ = function(t, index)
    local mt = getmetatable(t)
    if not mt then
        mt = {}
        -- gc
        if rawget(index, "__gc") then
            if not mt.__gc then
                mt.__gc = rawget(index, "__gc")
            end
        end
        if rawget(index, "__pairs") then
            if not mt.__pairs then
                mt.__pairs = rawget(index, "__pairs")
            end
        end
    end
    -- index
    if not mt.__index then
        mt.__index = index
        setmetatable(t, mt)
    elseif mt.__index ~= index then
        setmetatable_help_(mt, index)
    end

end
setmetatable_help = setmetatable_help_

-- local tRegisterClass = {}

function class(class_name, super, extra_meta)
    -- assert(not tRegisterClass[class_name], string.format("class() - has created class \"%s\" ", class_name))
    -- tRegisterClass[class_name] = true

    local super_type = type(super)
    assert("nil" == super_type or "table" == super_type,
            string.format("class() - create class \"%s\" with invalid super class type \"%s\"", class_name, super_type))

    local cls = { __cname = class_name }
    cls.super = super
    cls.__index = cls
    if extra_meta then
        if extra_meta.__gc then
            cls.__gc = extra_meta.__gc
        end
        if extra_meta.__pairs then
            cls.__pairs = extra_meta.__pairs
        end
    end
    setmetatable(cls, { __index = cls.super })

    if not cls.ctor then
        cls.ctor = function() end
    end

    cls.new = function(_, ...)
        local instance = {}
        setmetatable_help(instance, cls)
        -- setmetatable(instance, cls)
        instance._class_type = cls
        instance:ctor(...)
        return instance
    end

    return cls
end