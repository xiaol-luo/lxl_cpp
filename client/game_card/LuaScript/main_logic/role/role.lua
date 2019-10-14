
Role = Role or class("Role")

function Role:ctor()
    self.role_id = gen_next_seq()
end

local a = 37

local upvalue_fn_for_test = function()
    print("reach upvalue_fn_for_test 3")
    return function()
        print("hello world  2")
    end
end

local upvalue_fn_tell_a = function()
    -- print("upvalue_fn_tell_a a = ", a + 3)
    local hello_fn = upvalue_fn_for_test()
    hello_fn()
end

function Role:say_hi()
    -- print(string.format("role which role id = %s, say hi to you", self.role_id))
end

function Role:tell_a()
    -- print(string.format("role %s tells a = %s", self.role_id, a))
    -- upvalue_fn_tell_a()
end

print("reach role ")