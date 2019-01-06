#pragma once

#include "i_timer_module.h"
#include "timer_mgr.h"
#include <vector>
#include <map>
#include <set>

class TimerModule : public ITimerModule
{
public:
	TimerModule(ModuleMgr *module_mgr);
	virtual ~TimerModule();
	virtual EModuleRetCode Init(void *param);
	virtual EModuleRetCode Awake();
	virtual EModuleRetCode Update();
	virtual EModuleRetCode Release();
	virtual EModuleRetCode Destroy();

	virtual int64_t NowSec();
	virtual int64_t NowMs();
	virtual int64_t DeltaMs();
	virtual int64_t RealNowMs();
	virtual TimerID Add(TimerCallback cb_fn, uint64_t start_ts_ms, uint64_t execute_span_ms, uint64_t execute_times);
	virtual TimerID AddNext(TimerCallback cb_fn, uint64_t start_ts_ms);
	virtual TimerID AddFirm(TimerCallback cb_fn, uint64_t execute_span_ms, uint64_t execute_times);
	virtual void Remove(TimerID timer_id);

private:
	void UpdateTime();
	long long m_now_ms = 0;
	long long m_now_sec = 0;
	long long m_delta_ms = 0;

	TimerMgr *m_timer_mgr = nullptr;
};