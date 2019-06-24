#pragma once

#include "coro_def.h"
#include <unordered_set>
#include "coro.h"

class Coro : public std::enable_shared_from_this<Coro>
{
public:
	Coro(int64_t id, Coro_Create_Fn_Var_Var logic_fn);
	virtual ~Coro();

	CoroOpRet Resume(std::shared_ptr<CoroVar> in_param);
	CoroOpRet DoYield(std::shared_ptr<CoroVar> out_param);
	void ReleaseAll();
	ECoroStatus GetStatus() { return m_state; }
	int64_t GetId() { return m_id; }

public:
	int64_t m_id = 0;
	Coro_Create_Fn_Var_Var m_logic_fn = nullptr;
	std::shared_ptr<CoroVar> m_in_var = nullptr;
	std::shared_ptr<CoroVar> m_out_var = nullptr;
	std::unordered_set<std::shared_ptr<CoroVar>> m_in_var_history;
	ECoroStatus m_state = ECoroStatus_Suspended;

	static void coro_func(void *);
	coro_context *m_context = nullptr;
	coro_stack *m_stack = nullptr;
};