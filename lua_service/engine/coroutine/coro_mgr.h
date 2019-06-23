#pragma once

#include <stdint.h>
#include "coro_def.h"
#include "coro.h"
#include <unordered_map>

class CoroMgr
{
public:
	CoroMgr();
	~CoroMgr();

	int64_t Create(Coro_Create_Fn_Void_Void fn);
	CoroOpRet Resume(int64_t coro_id, std::shared_ptr<ICoroVar > in_param);
	CoroOpRet DoYield(std::shared_ptr<ICoroVar> out_param);
	void Kill(int64_t coro_id);
	void Status(int64_t coro_id);
	int64_t RunningCoroId();
	std::shared_ptr<Coro> GetCoro(int64_t coro_id);

private:
	std::shared_ptr<Coro> m_running_coro = nullptr;
	std::unordered_map<int64_t, std::shared_ptr<Coro>> m_coro_map;
};

void InitCoroMgr();


