#pragma once

#include "coro_def.h"
#include <unordered_set>

class Coro : public std::enable_shared_from_this<Coro>
{
public:
	Coro(Coro_Create_Fn_Var_Var logic_fn);
	virtual ~Coro();

protected:
	Coro_Create_Fn_Var_Var m_logic_fn = nullptr;
};