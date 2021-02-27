#include "lua_reg.h"
#include "fixed_number.h"
#include <string>
#include "lock_step/lock_step_set.hpp"

template <typename T>
struct reg_set_help
{
	using LockStepSetT = typename LockStepSet<T>;
	using LockStepSetIt = typename LockStepSetT::iterator;

	struct iterator_state 
	{
		iterator_state(LockStepSetT &ls_set) : it(ls_set.begin()), last(ls_set.end()) {}
		LockStepSetIt it;
		LockStepSetIt last;
	};

	static std::tuple<sol::object, sol::object> next(sol::user<iterator_state &> user_it_state, sol::this_state l)
	{
		iterator_state& it_state = user_it_state;
		auto &it = it_state.it;
		if (it == it_state.last)
		{
			return std::make_tuple(sol::object(sol::lua_nil), sol::object(sol::lua_nil));
		}
		auto r = std::make_tuple(sol::object(l, sol::in_place, *it), sol::object(l, sol::in_place, *it));
		++it;
		return r;
	}

	static auto pairs(LockStepSetT &ls_set)
	{
		iterator_state it_state(ls_set);
		return std::make_tuple(&next, sol::user<iterator_state>(std::move(it_state)), sol::lua_nil);
	}

	static bool insert(LockStepSetT &ls_set, const T &val)
	{
		auto ret = ls_set.insert(val);
		return ret.second;
	}

	static typename LockStepSetT::size_type erase(LockStepSetT &ls_set, const T &val)
	{
		return ls_set.erase(val);
	}

	static void do_reg(sol::main_table native_tb, std::string class_name)
	{
		sol::usertype<LockStepSetT> meta_table(
			sol::constructors<LockStepSetT()>(),
			sol::meta_method::pairs, &pairs,
			"erase", &erase,
			"insert", &insert,
			"exist", &LockStepSetT::exist,
			"clear", &LockStepSetT::clear
		);
		native_tb.set_usertype(class_name, meta_table);
	}
};


void lua_reg_lockstep_container(lua_State *L)
{
	sol::main_table native_tb = get_or_create_table(L, TB_NATIVE);
	reg_set_help<int32_t>::do_reg(native_tb, "LockStepSetInt");
	reg_set_help<int64_t>::do_reg(native_tb, "LockStepSetInt64");
	reg_set_help<double>::do_reg(native_tb, "LockStepSetNumber");
	reg_set_help<double>::do_reg(native_tb, "LockStepSetDouble");
	reg_set_help<float>::do_reg(native_tb, "LockStepSetFloat");
	reg_set_help<fixed_number>::do_reg(native_tb, "LockStepSetFixedNumber");
	reg_set_help<std::string>::do_reg(native_tb, "LockStepSetString");
	reg_set_help<sol::object>::do_reg(native_tb, "LockStepSetLuaObject");
}


