#include "lua_reg.h"
#include "fixed_number.h"
#include <string>

static fixed_number OperaSub(const fixed_number &p1, const fixed_number &p2)
{
	return p1 - p2;
}

static fixed_number OperaUnm(const fixed_number &p1, const fixed_number &p2)
{
	return -p1;
}

static fixed_number AtanOverLoad_1(fixed_number &p)
{
	return p.atan();
}

static fixed_number AtanOverLoad_2(fixed_number &p1, fixed_number &p2)
{
	return p1.atan(p2);
}

static fixed_number MakeOverLoad_1(const int& p)
{
	return fixed_number::make(p);
}

static fixed_number MakeOverLoad_2(const std::string& p)
{
	return fixed_number::make(p);
}

static std::string ToString(fixed_number &p)
{
	return std::to_string(float(p));
}

void lua_reg_fix_math(lua_State *L)
{
	sol::main_table native_tb = get_or_create_table(L, TB_NATIVE);
	// RedisTaskMgr
	std::string class_name = "FixNumber";
	sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
	assert(!v.valid());
	sol::usertype<fixed_number> meta_table(
		sol::constructors<fixed_number(), fixed_number(const int&), fixed_number(const std::string&), fixed_number(const fixed_number&) >(),
		sol::meta_method::addition, &fixed_number::operator+,
		sol::meta_method::subtraction, &OperaSub,
		sol::meta_method::multiplication, &fixed_number::operator*,
		sol::meta_method::division, &fixed_number::operator/,
		sol::meta_method::modulus, &fixed_number::operator%,
		sol::meta_method::power_of, &fixed_number::pow,
		sol::meta_method::unary_minus, &OperaUnm,
		sol::meta_method::less_than, &fixed_number::operator<,
		sol::meta_method::less_than_or_equal_to, &fixed_number::operator<=,
		sol::meta_method::equal_to, &fixed_number::operator==,
		sol::meta_method::to_string, &ToString,
		"is_inf", &fixed_number::isinf,
		"is_nan", &fixed_number::isnan,
		"floor", &fixed_number::floor,
		"ceil", &fixed_number::ceil,
		"abs", &fixed_number::abs,
		"sqrt", &fixed_number::sqrt,
		"pow", &fixed_number::pow,
		"sin", &fixed_number::sin,
		"cos", &fixed_number::cos,
		"tan", &fixed_number::tan,
		"asin", &fixed_number::asin,
		"acos", &fixed_number::acos,
		"atan", sol::overload(&AtanOverLoad_1, &AtanOverLoad_2),
		"exp", &fixed_number::exp,
		"log", &fixed_number::log,
		"max", sol::var(fixed_number::max),
		"epsilon", sol::var(fixed_number::epsilon),
		"one", sol::var(fixed_number::one),
		"zero", sol::var(fixed_number::zero),
		"pi", sol::var(fixed_number::pi),
		"raw_data", sol::property(&fixed_number::raw_data),
		"make", sol::overload(&MakeOverLoad_1, &MakeOverLoad_2)
	);
	native_tb.set_usertype(class_name, meta_table);
}
