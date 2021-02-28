#include "lua_reg.h"
#include "fixed_number.h"
#include <string>
#include "lock_step/lock_step_set.hpp"
#include "lock_step/lock_step_map.hpp"

template <typename T>
struct reg_set_help
{
	using LockStepSetT = LockStepSet<T>;
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

template <typename K, typename V>
struct reg_map_help 
{
	using LockStepMapT = LockStepMap<K, V>;
	using LockStepMapIt = typename LockStepMapT::iterator;

	struct iterator_state 
	{
		iterator_state(LockStepMapT &ls_set) : it(ls_set.begin()), last(ls_set.end()) {}
		LockStepMapIt it;
		LockStepMapIt last;
	};

	static std::tuple<sol::object, sol::object> next(sol::user<iterator_state &> user_it_state, sol::this_state l)
	{
		iterator_state& it_state = user_it_state;
		auto &it = it_state.it;
		if (it == it_state.last)
		{
			return std::make_tuple(sol::object(sol::lua_nil), sol::object(sol::lua_nil));
		}
		auto r = std::make_tuple(sol::object(l, sol::in_place, it->first), sol::object(l, sol::in_place, it->second));
		++it;
		return r;
	}

	static auto pairs(LockStepMapT &ls_set)
	{
		iterator_state it_state(ls_set);
		return std::make_tuple(&next, sol::user<iterator_state>(std::move(it_state)), sol::lua_nil);
	}

	static bool insert(LockStepMapT &ls_map, const K &key, const V &val)
	{
		auto ret = ls_map.insert(std::make_pair(key, val));
		return ret.second;
	}

	static typename LockStepMapT::size_type erase(LockStepMapT &ls_map, const K &val)
	{
		return ls_map.erase(val);
	}
	static void do_reg(sol::main_table native_tb, std::string class_name)
	{
		sol::usertype<LockStepMapT> meta_table(
			sol::constructors<LockStepMapT()>(),
			sol::meta_method::pairs, &pairs,
			"erase", &erase,
			"insert", &insert,
			"exist", &LockStepMapT::exist,
			"clear", &LockStepMapT::size
		);
		native_tb.set_usertype(class_name, meta_table);
	}
};


void lua_reg_lockstep_container(lua_State *L)
{
	
	sol::main_table native_tb = get_or_create_table(L, TB_NATIVE);
	reg_set_help<int32_t>::do_reg(native_tb, "LockStepSetI");
	
	reg_set_help<int64_t>::do_reg(native_tb, "LockStepSetL");
	reg_set_help<float>::do_reg(native_tb, "LockStepSetF");
	reg_set_help<std::string>::do_reg(native_tb, "LockStepSetS");
	reg_set_help<fixed_number>::do_reg(native_tb, "LockStepSetFn");
	reg_set_help<sol::object>::do_reg(native_tb, "LockStepSetO");

	
	{
		reg_map_help<int32_t, int32_t>::do_reg(native_tb, "LockStepMapII");
		reg_map_help<int32_t, int64_t>::do_reg(native_tb, "LockStepMapIL");
		reg_map_help<int32_t, float>::do_reg(native_tb, "LockStepMapIF");
		reg_map_help<int32_t, std::string>::do_reg(native_tb, "LockStepMapIS");
		reg_map_help<int32_t, fixed_number>::do_reg(native_tb, "LockStepMapIFn");
		reg_map_help<int32_t, sol::object>::do_reg(native_tb, "LockStepMapIO");
	}

	{
		reg_map_help<int64_t, int32_t>::do_reg(native_tb, "LockStepMapLI");
		reg_map_help<int64_t, int64_t>::do_reg(native_tb, "LockStepMapLL");
		reg_map_help<int64_t, float>::do_reg(native_tb, "LockStepMapLF");
		reg_map_help<int64_t, std::string>::do_reg(native_tb, "LockStepMapLS");
		reg_map_help<int64_t, fixed_number>::do_reg(native_tb, "LockStepMapLFn");
		reg_map_help<int64_t, sol::object>::do_reg(native_tb, "LockStepMapLO");
	}

	/*
	{
		reg_map_help<float, int32_t>::do_reg(native_tb, "LockStepMapFI");
		reg_map_help<float, int64_t>::do_reg(native_tb, "LockStepMapFL");
		reg_map_help<float, float>::do_reg(native_tb, "LockStepMapFF");
		reg_map_help<float, std::string>::do_reg(native_tb, "LockStepMapFS");
		reg_map_help<float, fixed_number>::do_reg(native_tb, "LockStepMapFFn");
		reg_map_help<float, sol::object>::do_reg(native_tb, "LockStepMapFO");
	}
	*/

	{
		reg_map_help<std::string, int32_t>::do_reg(native_tb, "LockStepMapSI");
		reg_map_help<std::string, int64_t>::do_reg(native_tb, "LockStepMapSL");
		reg_map_help<std::string, float>::do_reg(native_tb, "LockStepMapSF");
		reg_map_help<std::string, std::string>::do_reg(native_tb, "LockStepMapSS");
		reg_map_help<std::string, fixed_number>::do_reg(native_tb, "LockStepMapSFn");
		reg_map_help<std::string, sol::object>::do_reg(native_tb, "LockStepMapSO");
	}

	{
		reg_map_help<fixed_number, int32_t>::do_reg(native_tb, "LockStepMapFnI");
		reg_map_help<fixed_number, int64_t>::do_reg(native_tb, "LockStepMapFnL");
		reg_map_help<fixed_number, float>::do_reg(native_tb, "LockStepMapFnF");
		reg_map_help<fixed_number, std::string>::do_reg(native_tb, "LockStepMapFnS");
		reg_map_help<fixed_number, fixed_number>::do_reg(native_tb, "LockStepMapFnFn");
		reg_map_help<fixed_number, sol::object>::do_reg(native_tb, "LockStepMapFnO");
	}
	/*
	{
		reg_map_help<sol::object, int32_t>::do_reg(native_tb, "LockStepMapOI");
		reg_map_help<sol::object, int64_t>::do_reg(native_tb, "LockStepMapOL");
		reg_map_help<sol::object, float>::do_reg(native_tb, "LockStepMapOF");
		reg_map_help<sol::object, std::string>::do_reg(native_tb, "LockStepMapOS");
		reg_map_help<sol::object, fixed_number>::do_reg(native_tb, "LockStepMapOFn");
		reg_map_help<sol::object, sol::object>::do_reg(native_tb, "LockStepMapOO");
	}
	*/
}


