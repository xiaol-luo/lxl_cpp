#include "coro.hpp"
#include "coro_mgr.h"
#include <assert.h>

// extern CoroMgr *g_coro_mgr = nullptr;

Coro::Coro(int64_t id, Coro_Create_Fn_Var_Var logic_fn)
{
	assert(logic_fn);
	m_id = id;
	m_logic_fn = logic_fn;
	m_stack = new coro_stack();
	coro_stack_alloc(m_stack, 0);
	m_context = new coro_context();
	coro_create(m_context, Coro::coro_func, this, m_stack->sptr, m_stack->ssze);
}

Coro::~Coro()
{
	this->ReleaseAll();
}

CoroOpRet Coro::Resume(std::shared_ptr<CoroVar> in_param)
{
	CoroOpRet ret;
	m_in_var = in_param;

	if (ECoroStatus_Suspended != m_state)
	{
		ret.error_num = ECoroError_Not_Resumable;
		return ret;
	}

	m_state = ECoroStatus_Running;
	m_out_var = nullptr;
	m_in_var_history.insert(in_param);

	ret.ret = m_out_var;
	return ret;
}

CoroOpRet Coro::DoYield(std::shared_ptr<CoroVar> out_param)
{
	CoroOpRet ret;
	m_out_var = out_param;

	if (ECoroStatus_Running != m_state)
	{
		ret.error_num = ECoroError_Not_Yieldable;
		return ret;
	}
	m_state = ECoroStatus_Suspended;
	return ret;
}

void Coro::ReleaseAll()
{
	if (m_context)
	{
		coro_destroy(m_context);
		delete m_context;
		m_context = nullptr;
	}
	if (m_stack)
	{
		coro_stack_free(m_stack);
		delete m_stack;
		m_stack = nullptr;
	}
	m_in_var_history.clear();
	m_in_var = nullptr;
	m_out_var = nullptr;
}

void Coro::coro_func(void *arg)
{
	Coro * ptr = static_cast<Coro *>(arg);
	std::shared_ptr<Coro> This = ptr->shared_from_this();

	This->m_state = ECoroStatus_Dead;
}


