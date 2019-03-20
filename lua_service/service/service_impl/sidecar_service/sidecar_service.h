#pragma once

#include "service_impl/service_base.h"

class SidecarService : public ServiceBase
{
public:
	SidecarService() {}
	virtual ~SidecarService() {}
	virtual void RunService(int argc, char **argv) override;
	virtual EModuleRetCode Init(void **param) { return EModuleRetCode_Succ; }
	virtual EModuleRetCode Awake() { return EModuleRetCode_Succ; }
	virtual EModuleRetCode Release() { return EModuleRetCode_Succ; }
	virtual EModuleRetCode Destroy() { return EModuleRetCode_Succ; }

protected:
	virtual bool CanQuitGame() override;
	virtual void NotifyQuitGame() override;

	bool m_can_quit = false;
};
