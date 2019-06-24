#pragma once

#include <stdint.h>
#include "coro_def.h"
#include "coro.hpp"
#include <unordered_map>

class CoroMgr
{
public:
	CoroMgr();
	~CoroMgr();

	int64_t Create(Coro_Create_Fn_Var_Var fn);
	CoroOpRet Resume(int64_t coro_id, std::shared_ptr<CoroVar > in_param);
	CoroOpRet DoYield(std::shared_ptr<CoroVar> out_param);
	void Kill(int64_t coro_id);
	ECoroStatus Status(int64_t coro_id);
	int64_t RunningCoroId();
	std::shared_ptr<Coro> GetCoro(int64_t coro_id);

public:
	void CheckResetRunningCoro();
	std::shared_ptr<Coro> m_running_coro = nullptr;
	int64_t m_last_coro_id = 0;
	std::unordered_map<int64_t, std::shared_ptr<Coro>> m_coro_map;
	// ECoroStatus m_state = ECoroStatus_Dead;
	coro_context *m_context = nullptr;
};

void InitCoroMgr();
int64_t Coro_Create(Coro_Create_Fn_Var_Var fn);
CoroOpRet Coro_Resume(int64_t coro_id, std::shared_ptr<CoroVar > in_param);
CoroOpRet Coro_DoYield(std::shared_ptr<CoroVar> out_param);
ECoroStatus Coro_Status(int64_t coro_id);
int64_t Coro_RunningCoroId();

