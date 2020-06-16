#include "lua_reg.h"
#include "third_party/data_struct/consistent_hash/consistent_hash.h"
#include <string>

static std::tuple<bool, std::string> Wrap_Find_Address(ConsistentHash &hash, sol::object lua_obj)
{
	std::pair<bool, std::string> ret(false, "");
	switch (lua_obj.get_type())
	{
	case sol::type::string:
	{
		std::string &str = lua_obj.as<std::string>();
		ret = hash.FindAddress(str.data(), str.size());
	}
	break;
	case sol::type::number:
	{
		uint64_t num = lua_obj.as<uint64_t>();
		ret = hash.FindAddress(&num, sizeof(num));
	}
	break;
	default:
		break;
	}
	return std::make_tuple(ret.first, ret.second);
}

void lua_reg_consistent_hash(lua_State *L)
{
	sol::main_table native_tb = get_or_create_table(L, TB_NATIVE);
	// RedisTaskMgr
	std::string class_name = "ConsistentHash";
	sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
	assert(!v.valid());
	sol::usertype<ConsistentHash> meta_table(
		"set_real_node", &ConsistentHash::SetRealNode,
		"find_address", &Wrap_Find_Address
	);
	native_tb.set_usertype(class_name, meta_table);
}
