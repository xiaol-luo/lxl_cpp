#include "service_base.h"
#include "iengine.h"
#include "main_impl/main_impl.h"

EModuleRetCode ServiceBase::Update()
{
	if (State_Quiting == m_state)
	{
		if (this->CanQuitGame())
		{
			m_state = State_Quited;
			engine_stop();
		}
	}
	return EModuleRetCode_Pending;
}

void ServiceBase::TryQuitGame()
{
	if (State_Runing == m_state)
	{
		m_state = State_Quiting;
		this->NotifyQuitGame();
	}
}




