#pragma once

#include "service_imp/service_base.h"

class PureLuaService : public ServiceBase
{
public:
	PureLuaService() {}
	virtual ~PureLuaService() {}
	virtual EModuleRetCode Init(void **param) { return EModuleRetCode_Succ; }
	virtual EModuleRetCode Awake() { return EModuleRetCode_Succ; }
	virtual EModuleRetCode Release() { return EModuleRetCode_Succ; }
	virtual EModuleRetCode Destroy() { return EModuleRetCode_Succ; }

protected:
	virtual bool CanQuitGame() override;
	virtual void NotifyQuitGame() override;
};
