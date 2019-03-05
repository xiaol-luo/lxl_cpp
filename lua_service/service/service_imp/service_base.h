#pragma once

#include "i_service.h"

class ServiceBase : public IService
{
public:
	virtual EModuleRetCode Update();
	void TryQuitGame();

protected:
	enum State 
	{
		State_Runing,
		State_Quiting,
		State_Quited,
	};
	State m_state = State_Runing;
	virtual bool CanQuitGame() = 0;
	virtual void NotifyQuitGame() = 0;
};
