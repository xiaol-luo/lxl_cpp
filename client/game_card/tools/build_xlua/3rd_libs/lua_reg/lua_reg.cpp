#include "lua_reg.h"

sol::main_table get_or_create_table(lua_State *L, std::string tb_name)
{
	sol::state_view lsv(L);
	sol::object v = lsv.get<sol::object>(tb_name);
	if (!v.is<sol::main_table>())
	{
		// 如果table不存在，那么只应该为nil，否则会有覆盖有效数据的风险
		assert(v.is<sol::nil_t>());
		lsv.create_named_table(tb_name);
	}
	return lsv[tb_name];
}

void register_native_libs(lua_State *L)
{
	sol::state_view sv(L);
	sol::main_table t = get_or_create_table(L, TB_NATIVE);
	lua_reg_fix_math(L);	
}