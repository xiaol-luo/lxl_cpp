#include "coro_mgr.h"
#include <assert.h>

static CoroMgr *g_coro_mgr = nullptr;

void InitCoroMgr()
{
	assert(!g_coro_mgr);
	g_coro_mgr = new CoroMgr();
}

CoroMgr::CoroMgr()
{
}

CoroMgr::~CoroMgr()
{
}

int64_t CoroMgr::Create(Coro_Create_Fn_Void_Void fn)
{
	return int64_t();
}

CoroOpRet CoroMgr::Resume(int64_t coro_id, std::shared_ptr<ICoroVar> in_param)
{
	return CoroOpRet();
}

CoroOpRet CoroMgr::DoYield(std::shared_ptr<ICoroVar> out_param)
{
	return CoroOpRet();
}

void CoroMgr::Kill(int64_t coro_id)
{
}

void CoroMgr::Status(int64_t coro_id)
{
}

int64_t CoroMgr::RunningCoroId()
{
	return int64_t();
}

std::shared_ptr<Coro> CoroMgr::GetCoro(int64_t coro_id)
{
	return std::shared_ptr<Coro>();
}
