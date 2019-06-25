#pragma once

#include "coro_def.h"
#include <unordered_set>

class Coro : public std::enable_shared_from_this<Coro>
{
public:
	Coro(int64_t id, Coro_Create_Fn_Var_Var logic_fn, std::shared_ptr<CoroVarBase> fn_param);
	virtual ~Coro();

	CoroOpRet Resume(std::shared_ptr<CoroVarBase> in_param);
	CoroOpRet DoYield(std::shared_ptr<CoroVarBase> out_param);
	void ReleaseAll();
	ECoroStatus GetStatus() { return m_state; }
	int64_t GetId() { return m_id; }

public:
	int64_t m_id = 0;
	Coro_Create_Fn_Var_Var m_logic_fn = nullptr;
	std::shared_ptr<CoroVarBase> m_logic_param = nullptr;
	Coro_Create_Fn_Void_Void m_execute_fn = nullptr;
	std::shared_ptr<CoroVarBase> m_in_var = nullptr;
	std::shared_ptr<CoroVarBase> m_out_var = nullptr;
	std::shared_ptr<CoroVarBase> m_over_var = nullptr;
	std::unordered_set<std::shared_ptr<CoroVarBase>> m_in_var_history;
	ECoroStatus m_state = ECoroStatus_Suspended;

	unsigned m_rt = -1;
	void coro_func();

};