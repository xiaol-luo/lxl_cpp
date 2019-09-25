#pragma once

#include "module_def/i_module.h"
#include "module_def/module_mgr.h"

class IService : public IModule
{
public:
	IService() : IModule(nullptr, EModuleName_ServiceLogic) {}
};
