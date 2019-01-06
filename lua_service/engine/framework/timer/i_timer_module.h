#pragma once

#include "module_def/i_module.h"
#include <memory>
#include <functional>
#include "timer_def.h"

class ITimerModule : public IModule
{
public:
	const static EMoudleName MODULE_NAME = EMoudleName_TIMER;
	ITimerModule(ModuleMgr *module_mgr) : IModule(module_mgr, MODULE_NAME) {}
	virtual ~ITimerModule() {}
	virtual EModuleRetCode Init(void *param) = 0;
	virtual EModuleRetCode Awake() = 0;
	virtual EModuleRetCode Update() = 0;
	virtual EModuleRetCode Release() = 0;
	virtual EModuleRetCode Destroy() = 0;

	virtual int64_t NowSec() = 0;
	virtual int64_t NowMs() = 0;
	virtual int64_t DeltaMs() = 0;
	virtual int64_t RealNowMs() = 0;

	virtual TimerID Add(TimerCallback action, int64_t start_ts_ms, int64_t execute_span_ms, int64_t execute_times) = 0;
	virtual TimerID AddNext(TimerCallback action, int64_t start_ts_ms) = 0;
	virtual TimerID AddFirm(TimerCallback action, int64_t execute_span_ms, int64_t execute_times) = 0;
	virtual void Remove(TimerID timer_id) = 0;
};
