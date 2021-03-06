#include "coro_mgr.h"
#include <assert.h>

CoroMgr::CoroMgr()
{

}

CoroMgr::~CoroMgr()
{

}

int64_t CoroMgr::Create(Coro_Create_Fn_Var_Var fn, std::shared_ptr<CoroVarBase> fn_param)
{
	++m_last_coro_id;
	std::shared_ptr<Coro> item = std::make_shared<Coro>(m_last_coro_id, fn, fn_param);
	m_coro_map.insert(std::make_pair(m_last_coro_id, item));
	return m_last_coro_id;
}

CoroOpRet CoroMgr::Resume(int64_t coro_id, std::shared_ptr<CoroVarBase> in_param)
{
	this->CheckResetRunningCoro();
	if (m_running_coro)
	{
		return CoroOpRet(ECoroError_Other_Coro_Running, nullptr);
	}
	std::shared_ptr<Coro> coro = this->GetCoro(coro_id);
	if (!coro)
	{
		return CoroOpRet(ECoroError_Not_Find, nullptr);
	}

	m_running_coro = coro;
	CoroOpRet ret = coro->Resume(in_param);
	return ret;
}

CoroOpRet CoroMgr::DoYield(std::shared_ptr<CoroVarBase> out_param)
{
	this->CheckResetRunningCoro();

	int64_t coro_id = this->Running();
	if (coro_id <= 0)
	{
		return CoroOpRet(ECoroError_Not_Running_Coro, nullptr);
	}
	std::shared_ptr<Coro> coro = this->GetCoro(coro_id);
	if (!coro)
	{
		return CoroOpRet(ECoroError_Not_Find, nullptr);
	}

	CoroOpRet ret = coro->DoYield(out_param);
	return ret;
}

ECoroStatus CoroMgr::Status(int64_t coro_id)
{
	ECoroStatus ret = ECoroStatus_Dead;
	std::shared_ptr<Coro> coro = this->GetCoro(coro_id);
	if (coro)
	{
		ret = coro->GetStatus();
	}
	return ret;
}

int64_t CoroMgr::Running()
{
	this->CheckResetRunningCoro();

	int64_t ret = 0;
	if (m_running_coro)
	{
		ret = m_running_coro->GetId();
	}
	return ret;
}

std::shared_ptr<Coro> CoroMgr::GetCoro(int64_t coro_id)
{
	std::shared_ptr<Coro> ret = nullptr;
	auto it = m_coro_map.find(coro_id);
	if (m_coro_map.end() != it)
	{
		ret = it->second;
	}
	return ret;
}

void CoroMgr::CheckResetRunningCoro()
{
	if (m_running_coro && ECoroStatus_Dead == m_running_coro->GetStatus())
	{
		int64_t coro_id = m_running_coro->GetId();
		m_coro_map.erase(coro_id);
		m_running_coro = nullptr;
	}
	if (m_running_coro && ECoroStatus_Suspended == m_running_coro->GetStatus())
	{
		m_running_coro = nullptr;
	}
}

void CoroMgr::Kill(int64_t coro_id)
{
	auto coro = GetCoro(coro_id);
	if (coro && ECoroStatus_Dead != coro->GetStatus())
	{
		if (ECoroStatus_Running == coro->GetStatus())
		{
			coro->Kill();
			// 后边的代码不会执行了
		}
		else
		{
			m_coro_map.erase(coro_id);
			coro->Kill();
		}
	}
}


CoroMgr *g_coro_mgr = nullptr;

void InitCoroMgr()
{
	assert(!g_coro_mgr);
	g_coro_mgr = new CoroMgr();
}

int64_t Coro_Create(Coro_Create_Fn_Var_Var fn, std::shared_ptr<CoroVarBase> fn_param)
{
	return g_coro_mgr->Create(fn, fn_param);
}

CoroOpRet Coro_Resume(int64_t coro_id, std::shared_ptr<CoroVarBase> in_param)
{
	return g_coro_mgr->Resume(coro_id, in_param);
}

CoroOpRet Coro_Yield(std::shared_ptr<CoroVarBase> out_param)
{
	return g_coro_mgr->DoYield(out_param);
}

void Coro_Kill(int64_t coro_id)
{
	g_coro_mgr->Kill(coro_id);
}

ECoroStatus Coro_Status(int64_t coro_id)
{
	return g_coro_mgr->Status(coro_id);
}

int64_t Coro_Running()
{
	return g_coro_mgr->Running();
}