extern "C" 
{
	#include "lua.h"
	#include "lauxlib.h"
	#include "lualib.h"
}

#if WIN32
#include <WinSock2.h>
#include <direct.h>
#define chdir _chdir
#else
#include <arpa/inet.h>
#include <unistd.h>
#endif

#include "sol/sol.hpp"
#include <signal.h>
#include <memory>
#include "iengine.h"
#include "lua_reg/lua_reg.h"
#include <mongocxx/instance.hpp>
#include "main_impl/main_impl.h"
#include "service_impl/service_base.h"
#include "service_impl/pure_lua_service/pure_lua_service.h"
#include "service_impl/sidecar_service/sidecar_service.h"

lua_State *g_lua_state;

void QuitGame(int signal)
{
	try_quit_game();
}

std::shared_ptr<CoroVarBase> test_coro(std::shared_ptr<CoroVarBase> in_param)
{
	log_debug("test_coro here 1");

	std::shared_ptr<CoroVarBase> xx = std::make_shared<CoroVarBase>(nullptr);
	auto xxx = Coro_Yield(xx);
	log_debug("test_coro here 2");
	return xx;
}

struct TestCoroVar
{
	int int_val = 0;
	float float_val = 0;
};

int main (int argc, char **argv) 
{
#ifdef WIN32
	WSADATA wsa_data;
	WSAStartup(0x0201, &wsa_data);
#endif

	// argv: exe_name work_dir lua_file lua_file_params...
	if (argc <= Args_Index_Min_Value)
	{
		printf("exe_name service_name work_dir data_dir lua_scrip_dir other_params... --lua_args_begin-- lua_params...\n");
		return -10;
	}

	// change work dir
	char *work_dir = argv[Args_Index_WorkDir];
	printf("work dir is %s\n", work_dir);
	if (0 != chdir(work_dir))
	{
		printf("change work dir fail errno %d , dir is %s\n", errno, work_dir);
		return -20;
	}

	std::string service_name = ExtractServiceName(argv[Args_Index_Service_Name]);
	start_log(ELogLevel_Debug, service_name);
	engine_init();

	if (true)
	{
		TestCoroVar coro_var;
		coro_var.int_val = 1;
		coro_var.float_val = 1;
		std::make_shared<CoroVar<TestCoroVar> >(coro_var, nullptr);
	}
	if (true)
	{
		int64_t coro_id = Coro_Create(test_coro, nullptr);
		{
			TestCoroVar coro_var;
			coro_var.int_val = 1;
			coro_var.float_val = 1;
			std::shared_ptr<CoroVarBase> v = std::make_shared<CoroVar<TestCoroVar>>(coro_var, nullptr);
			CoroOpRet ret1 = Coro_Resume(coro_id, v);
			printf("xxxxxxxxxxxxxxxx 1\n");
		}
		{
			TestCoroVar *coro_var = new TestCoroVar();
			coro_var->int_val = 2;
			coro_var->float_val = 2;
			std::shared_ptr<CoroVarBase> v = std::make_shared<CoroVar<TestCoroVar *> >(coro_var, nullptr);
			CoroOpRet ret1 = Coro_Resume(coro_id, v);
			printf("xxxxxxxxxxxxxxxx 2\n");
		}
	}

	ServiceBase *service = nullptr;
	// const char *service_name = argv[Args_Index_Service_Name];
	if (nullptr == service && "sidecar" == service_name)
	{
		SidecarService *sidecar_service = new SidecarService();
		service = sidecar_service;
	}
	if (nullptr == service)
	{
		PureLuaService *pure_service = new PureLuaService();
		pure_service->SetFuns("OnNotifyQuitGame", "CheckCanQuitGame");
		service = pure_service;
	}

	void *ls_mem = mempool_malloc(sizeof(sol::state));
	sol::state *ls = new(ls_mem)sol::state(lua_panic_error, LuaAlloc);
	lua_State *L = ls->lua_state();
	g_lua_state = L;
	sol::protected_function::set_default_handler(sol::object(L, sol::in_place, lua_pcall_error));
	service->SetLuaState(L);

#ifdef WIN32
	signal(SIGINT, QuitGame);
	signal(SIGBREAK, QuitGame);
#else
	signal(SIGINT, QuitGame);
	signal(SIGPIPE, SIG_IGN);
#endif

	mongocxx::instance ins{};

	engine_loop_span(100);
	setup_service(service);  
	const int FLUSH_LOG_SPAN_MS = 10 * 1000;
	timer_firm(std::bind(flush_log), FLUSH_LOG_SPAN_MS, EXECUTE_UNLIMIT_TIMES);
	timer_firm(std::bind([ls]() { ls->collect_garbage(); }), FLUSH_LOG_SPAN_MS, EXECUTE_UNLIMIT_TIMES);
	timer_next(std::bind(&ServiceBase::RunService, service, argc, argv), 0);
	service = nullptr; // engine own the service
	engine_loop();
	ls->collect_garbage();
	ls->~state(); ls = nullptr;
	stop_log();
	mempool_free(ls_mem); ls_mem = nullptr;
	engine_destroy();
	return 0;
}

