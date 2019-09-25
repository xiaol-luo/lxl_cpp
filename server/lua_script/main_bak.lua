
local function parse_cmd_args(out_ret)
    local fn_is_cmd_prefix = function(s)
        local ret = string.find(s, "-") == 1
        return ret
    end

    local TbKey_Package_Path = "package_path"
    local TbKey_Package_CPath = "package_cpath"

    local parse_fns = {}
    parse_fns["-package_path"] = function(args, arg_idx, ret)
        ret[TbKey_Package_Path] = ret[TbKey_Package_Path] or {}
        local t = ret[TbKey_Package_Path]
        local curr_idx = arg_idx
        while curr_idx <= #args do
            local curr_arg = args[curr_idx]
            if fn_is_cmd_prefix(curr_arg) then
                break
            end
            table.insert(t, curr_arg)
            curr_idx = curr_idx + 1
        end
        return curr_idx - arg_idx
    end
    parse_fns["-package_cpath"] = function(args, arg_idx, ret)
        ret["package_cpath"] = ret["package_cpath"] or {}
        local t = ret["package_cpath"]
        local curr_idx = arg_idx
        while curr_idx <= #args do
            local curr_arg = args[curr_idx]
            if fn_is_cmd_prefix(curr_arg) then
                break
            end
            table.insert(t, curr_arg)
            curr_idx = curr_idx + 1
        end
        return curr_idx - arg_idx
    end

    out_ret = out_ret or {}
    local all_ok = true
    local arg_idx = 1
    while arg_idx <= #arg do
        local curr_arg = arg[arg_idx]
        if not fn_is_cmd_prefix(curr_arg) then
            all_ok = false
            break
        end
        local fn = parse_fns[curr_arg]
        if nil == fn then
            all_ok = false
            break
        end
        local consume_arg_count = fn(arg, arg_idx + 1, out_ret)
        arg_idx = arg_idx + 1 + consume_arg_count
    end
    if all_ok then
        if out_ret[TbKey_Package_Path] then
            for _, v in ipairs(out_ret[TbKey_Package_Path]) do
                if v then
                    package.path = string.format("%s;%s/?.lua;%s/?/init.lua", package.path, v, v)
                end
            end
        end
        if out_ret[TbKey_Package_CPath] then
            for _, v in ipairs(out_ret[TbKey_Package_CPath]) do
                if v then
                    package.cpath = string.format("%s;%s/?.dll;", package.cpath, v)
                end
            end
        end
    end
    return all_ok
end

print("before parse \n")
print("package.cpath:")
print(package.cpath)
print("\n")
print("package.path:")
print(package.path)

out_ret = {}
parse_cmd_args(out_ret)

print("after parse \n")
print("before parse \n")
print("package.cpath:")
print(package.cpath)
print("\n")
print("package.path:")
print(package.path)

local sproto = require "sproto"
local core = require "sproto.core"
local print_r = require "print_r"

local sp = sproto.parse [[
.Person {
	name 0 : string
	id 1 : integer
	email 2 : string

	.PhoneNumber {
		number 0 : string
		type 1 : integer
	}

	phone 3 : *PhoneNumber
}

.AddressBook {
	person 0 : *Person(id)
	others 1 : *Person
}
]]

-- core.dumpproto only for debug use
core.dumpproto(sp.__cobj)

local def = sp:default "Person"
print("default table for Person")
print_r(def)
print("--------------")

local ab = {
	person = {
		[10000] = {
			name = "Alice",
			id = 10000,
			phone = {
				{ number = "123456789" , type = 1 },
				{ number = "87654321" , type = 2 },
			}
		},
		[20000] = {
			name = "Bob",
			id = 20000,
			phone = {
				{ number = "01234567890" , type = 3 },
			}
		}
	},
	others = {
		{
			name = "Carol",
			id = 30000,
			phone = {
				{ number = "9876543210" },
			}
		},
	}
}

collectgarbage "stop"

local code = sp:encode("AddressBook", ab)
local addr = sp:decode("AddressBook", code)
print_r(addr)


local pb = require "pb"
local protoc = require "protoc"

assert(protoc:load [[
   message Phone {
      optional string name        = 1;
      optional int64  phonenumber = 2;
   }
   message Person {
      optional string name     = 1;
      optional int32  age      = 2;
      optional string address  = 3;
      repeated Phone  contacts = 4;
   } ]])

local data = {
   name = "ilse",
   age  = 18,
   contacts = {
      { name = "alice", phonenumber = 12312341234 },
      { name = "bob",   phonenumber = 45645674567 }
   }
}

for name, basename, type in pb.types() do
    print(name, basename, type)
  end

local bytes = assert(pb.encode("Person", data))
print(pb.tohex(bytes))

local data2 = assert(pb.decode("Person", bytes))
print(require "libs.serpent".block(data2))

local p = protoc:new()
p:addpath("Proto")

p:loadfile("Battle.proto")
p:loadfile("BattleEnum.proto")

local proto_files = {
    "msg.proto",
	"test.proto",
	"Battle.proto",
	"ProtoId.proto",
	"Common.proto",
	"Empty.proto",
	"BattleEnum.proto",
	"try.proto",
	"Instruction.proto"
}

for i, v in ipairs(proto_files) do
    p:loadfile(v)
end

for name, basename, type in pb.types() do
    print(name, basename, type)
end



--[[
message TryItem
{
	int32 id = 1;
	string name = 2;
}
--]]

local try_item = {
    id = 1,
    name = "hello"
}

local item_bytes = assert(pb.encode("NetProto.TryItem", try_item))
print(pb.tohex(item_bytes))

local item_data2 = assert(pb.decode("NetProto.TryItem", item_bytes))
print(require "libs.serpent".block(item_data2))


