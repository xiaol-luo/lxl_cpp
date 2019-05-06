#include "cross_platform_adapter.h"
#include "crossguid/guid.hpp"

std::string GenUuid()
{
	auto g = xg::newGuid();
	return g.str();
}