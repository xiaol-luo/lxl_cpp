#include "ServerLogic.h"
#include <thread>
#include <chrono>
#include <ctime>
#include "module_def/module_mgr.h"

#ifdef WIN32
static int getpagesize() { return 4096; }
#else
#include <unistd.h>
#endif // WIN32



extern int64_t RealMs();

ServerLogic *server_logic = nullptr;
const int TRY_MAX_TIMES = 100000;

ServerLogic::ServerLogic()
{
	m_module_mgr = new ModuleMgr(this);
	m_log_mgr = new LogMgr();
	m_timer_mgr = new TimerMgr(RealMs());
	memset(m_module_params, 0, sizeof(m_module_params));

	std::vector<uint32_t> bolck_sizes = { 8, 16, 32, 64, 96, 128, 256, 384, 512, 1024, 2048, 5120};
	m_memory_pool_mgr = new MemoryPoolMgr(bolck_sizes, getpagesize(), 8, 32);
}

ServerLogic::~ServerLogic()
{
	delete m_module_mgr; m_module_mgr = nullptr;
	delete m_timer_mgr; m_timer_mgr = nullptr;
	m_log_mgr->Stop();
	delete m_log_mgr; m_log_mgr = nullptr;
	delete m_memory_pool_mgr;
}

bool ServerLogic::StartLog(ELogLevel log_lvl)
{
	return m_log_mgr->Start(log_lvl);
}

bool ServerLogic::Init()
{
	if (EServerLogicState_Free != m_state)
		return false;

	m_state = EServerLogicState_Init;
	int loop_times = 0;
	EModuleRetCode retCode = EModuleRetCode_Succ;
	do
	{
		this->OnFrame();
		retCode = m_module_mgr->Init(m_module_params);
		std::this_thread::sleep_for(std::chrono::milliseconds(m_loop_span_ms));
	} while (EModuleRetCode_Pending == retCode && loop_times++ < TRY_MAX_TIMES);

	bool ret = EModuleRetCode_Succ == retCode;
	if (!ret)
	{
		this->Quit();
	}
	return ret;
}

bool ServerLogic::Awake()
{
	if (EServerLogicState_Init != m_state)
		return false;

	m_state = EServerLogicState_Awake;
	int loop_times = 0;
	EModuleRetCode retCode = EModuleRetCode_Succ;
	do
	{
		this->OnFrame();
		retCode = m_module_mgr->Awake();
		std::this_thread::sleep_for(std::chrono::milliseconds(m_loop_span_ms));
	} while (EModuleRetCode_Pending == retCode && loop_times++ < TRY_MAX_TIMES);

	bool ret = EModuleRetCode_Succ == retCode;
	if (!ret) this->Quit();
	return ret;
}

void ServerLogic::Update()
{
	if (EServerLogicState_Awake != m_state)
		return;

	m_state = EServerLogicState_Update;
	EModuleRetCode retCode = EModuleRetCode_Succ;
	do
	{
		this->OnFrame();
		retCode = m_module_mgr->Update();
		if (EModuleRetCode_Failed == retCode)
		{
			this->Quit();
		}

		int64_t real_ms = RealMs();
		int64_t logic_ms = this->LogicMs();
		int64_t consume_ms = real_ms - logic_ms;
		consume_ms = consume_ms >= 0 ? consume_ms : 0;
		// m_log_mgr->Debug("consume_ms {0}", consume_ms);
		long long sleep_time = m_loop_span_ms - consume_ms;
		if (sleep_time > 0)
			std::this_thread::sleep_for(std::chrono::milliseconds(sleep_time));
	} while (EServerLogicState_Update == m_state );
}

void ServerLogic::Realse()
{
	m_state = EServerLogicState_Release;
	int loop_times = 0;
	EModuleRetCode retCode = EModuleRetCode_Succ;
	do
	{
		this->OnFrame();
		retCode = m_module_mgr->Realse();
		std::this_thread::sleep_for(std::chrono::milliseconds(m_loop_span_ms));
		
	} while (EModuleRetCode_Pending == retCode && loop_times++ < TRY_MAX_TIMES);
}

void ServerLogic::Destroy()
{
	m_state = EServerLogicState_Destroy;
	int loop_times = 0;
	EModuleRetCode retCode = EModuleRetCode_Succ;
	do
	{
		this->OnFrame();
		retCode = m_module_mgr->Destroy();
		this->OnFrame();
		std::this_thread::sleep_for(std::chrono::milliseconds(m_loop_span_ms));
	} while (EModuleRetCode_Pending == retCode && loop_times++ < TRY_MAX_TIMES);

	if (nullptr != m_module_params_clear_fn)
	{
		m_module_params_clear_fn(m_module_params);
	}
}

void ServerLogic::Loop()
{
	this->OnFrame();
	bool ret = true;
	ret = ret && this->Init();
	ret = ret && this->Awake();
	this->Update();
	this->Realse();
	this->Destroy();
	m_state = EServerLogicState_Max;
	this->OnFrame();
}

void ServerLogic::Quit()
{
	if (m_state <= EServerLogicState_Update)
	{
		m_state = EServerLogicState_Release;
	}
}

INetworkModule * ServerLogic::GetNet()
{
	return m_module_mgr->GetModule<INetworkModule>();
}

void ServerLogic::OnFrame()
{
	uint64_t old_ms = m_logic_ms;
	m_logic_ms = RealMs();
	m_logic_sec = m_logic_ms / 1000.0;
	if (m_logic_ms > old_ms)
	{
		m_delta_ms = m_logic_ms - old_ms;
	}
	else
	{
		m_delta_ms = 0;
	}
	m_timer_mgr->UpdateTime(m_logic_ms);
	// m_log_mgr->Flush();
}