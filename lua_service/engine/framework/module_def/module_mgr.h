#pragma once

#include <memory>
#include "i_module.h"

class ServerLogic;

class ModuleMgr
{
public:
	ModuleMgr(ServerLogic *server_logic);
	~ModuleMgr();

	EModuleRetCode Init(void * init_params[EMoudleName_Max]);
	EModuleRetCode Awake();
	EModuleRetCode Update();
	EModuleRetCode Realse();
	EModuleRetCode Destroy();
	void Quit();

	bool SetModule(IModule *module);
	template <typename T> T * GetModule() 
	{ 
		IModule *module = this->GetModule(T::MODULE_NAME);
		return dynamic_cast<T *>(module);
	}
	IModule *GetModule(EMoudleName module_name);

private:
	bool m_is_free = true;
	IModule *m_modules[EMoudleName_Max];
};
