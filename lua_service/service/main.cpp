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

void QuitGame(int signal)
{
	IService *service = engine_service();
	ServiceBase *service_base = dynamic_cast<ServiceBase *>(service);
	if (nullptr != service_base)
	{
		service_base->TryQuitGame();
		log_debug("TryQuitGame");
	}
	else
	{
		printf("QuitGame");
		exit(0);
	}
}

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

	ServiceBase *service = nullptr;
	const char *service_name = argv[Args_Index_Service_Name];
	if (nullptr == service && 0 == std::strcmp(service_name, "sidecar"))
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

	sol::state ls(lua_panic_error);
	lua_State *L = ls.lua_state();
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

	engine_init();
	engine_loop_span(100);
	start_log(ELogLevel_Debug);
	setup_service(service);  
	timer_next(std::bind(&ServiceBase::RunService, service, argc, argv), 0);
	service = nullptr; // engine own the service
	engine_loop();
	engine_destroy();
	return 0;
}

