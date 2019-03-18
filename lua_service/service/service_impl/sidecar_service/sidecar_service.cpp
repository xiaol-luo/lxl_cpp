#include "sidecar_service.h"
#include <sol/sol.hpp>
#include "iengine.h"

void SidecarService::RunService(int argc, char ** argv)
{
}

bool SidecarService::CanQuitGame()
{
	return m_can_quit;
}

void SidecarService::NotifyQuitGame()
{
	m_can_quit = true;
}
