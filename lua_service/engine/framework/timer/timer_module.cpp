#include "timer_module.h"
#include <chrono>
#include <queue>
#include "module_def/module_mgr.h"
#include "log/log_module.h"

TimerModule::TimerModule(ModuleMgr *module_mgr) : ITimerModule(module_mgr)
{
}

TimerModule::~TimerModule()
{

}

EModuleRetCode TimerModule::Init(void *param)
{
	this->UpdateTime();
	m_timer_mgr = new TimerMgr(m_now_ms);
	return EModuleRetCode_Succ;
}

EModuleRetCode TimerModule::Awake()
{
	return EModuleRetCode_Succ;
}

EModuleRetCode TimerModule::Update()
{
	this->UpdateTime();
	m_timer_mgr->UpdateTime(m_now_ms);
	return EModuleRetCode_Pending;
}

EModuleRetCode TimerModule::Release()
{
	this->UpdateTime();
	delete m_timer_mgr; m_timer_mgr = nullptr;
	return EModuleRetCode_Succ;
}

EModuleRetCode TimerModule::Destroy()
{
	m_now_ms = this->RealNowMs();
	return EModuleRetCode_Succ;
}

int64_t TimerModule::NowSec()
{
	return m_now_sec;
}

int64_t TimerModule::NowMs()
{
	return m_now_ms;
}

int64_t TimerModule::DeltaMs()
{
	return m_delta_ms;
}

int64_t TimerModule::RealNowMs()
{
	std::chrono::high_resolution_clock::time_point tp = std::chrono::high_resolution_clock::now();
	long long now = std::chrono::duration_cast<std::chrono::milliseconds>(tp.time_since_epoch()).count();
	return now;
}

TimerID TimerModule::Add(TimerCallback cb_fn, uint64_t start_ts_ms, uint64_t execute_span_ms, uint64_t execute_times)
{
	return m_timer_mgr->Add(cb_fn, start_ts_ms, execute_span_ms, execute_times);
}

TimerID TimerModule::AddNext(TimerCallback cb_fn, uint64_t start_ts_ms)
{
	return m_timer_mgr->AddNext(cb_fn, start_ts_ms);
}

TimerID TimerModule::AddFirm(TimerCallback cb_fn, uint64_t execute_span_ms, uint64_t execute_times)
{
	return m_timer_mgr->AddFirm(cb_fn, execute_span_ms, execute_times);
}

void TimerModule::Remove(TimerID timer_id)
{
	m_timer_mgr->Remove(timer_id);
}

void TimerModule::UpdateTime()
{
	long long old_ms = m_now_ms;
	m_now_ms = this->RealNowMs();
	m_now_sec = m_now_ms / 1000;
	m_delta_ms = m_now_ms - old_ms;
}