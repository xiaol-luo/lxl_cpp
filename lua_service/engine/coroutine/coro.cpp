#include "coro.hpp"
#include "coro_mgr.h"
#include <assert.h>
#include <functional>
#include "coroutine/coroutine.h"

extern CoroMgr *g_coro_mgr;

Coro::Coro(int64_t id, Coro_Create_Fn_Var_Var logic_fn, std::shared_ptr<CoroVarBase> fn_param)
{
	assert(logic_fn);
	m_id = id;
	m_logic_fn = logic_fn;
	m_logic_param = fn_param;
	m_rt = coroutine::create(std::bind(&Coro::coro_func, this));
}

Coro::~Coro()
{
	this->ReleaseAll();
}

CoroOpRet Coro::Resume(std::shared_ptr<CoroVarBase> in_param)
{
	CoroOpRet ret;
	m_in_var = in_param;

	if (ECoroStatus_Suspended != m_state)
	{
		ret.error_num = ECoroError_Not_Resumable;
		return ret;
	}

	m_out_var = nullptr;
	m_in_var_history.insert(in_param);

	m_state = ECoroStatus_Running;
	coroutine::resume(m_rt);

	if (ECoroStatus_Dead == m_state)
	{
		ret.ret = m_over_var;
	}
	else
	{
		ret.ret = m_out_var;
	}
	return ret;
}

CoroOpRet Coro::DoYield(std::shared_ptr<CoroVarBase> out_param)
{
	CoroOpRet ret;
	m_out_var = out_param;

	if (ECoroStatus_Running != m_state)
	{
		ret.error_num = ECoroError_Not_Yieldable;
		return ret;
	}

	m_state = ECoroStatus_Suspended;
	coroutine::yield();
	ret.ret = m_in_var;
	return ret;
}

void Coro::ReleaseAll()
{
	coroutine::destroy(m_rt);
	m_in_var_history.clear();
	m_in_var = nullptr;
	m_out_var = nullptr;
}

void Coro::coro_func()
{
	this->m_over_var = m_logic_fn(m_logic_param);
	this->m_state = ECoroStatus_Dead;
}


