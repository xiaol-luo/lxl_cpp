#ifndef _WIN32

#include "cross_platform_adapter.h"

std::vector<std::string> ExtractNetIps()
{
	std::vector<std::string> out_ret;
	out_ret.push_back("127.0.0.1");
	return out_ret;
}

#endif
