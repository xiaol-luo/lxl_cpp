#include "redis_def.h"

RedisTask::~RedisTask()
{
	if (nullptr != reply)
	{
		freeReplyObject(reply);
		reply = nullptr;
	}
	if (nullptr != argv)
	{
		for (int i = 0; i < argc; ++i)
		{
			free(argv[i]); argv[i] = nullptr;
		}
		free(argv); argv = nullptr;
	}
	if (nullptr != argv_len)
	{
		free(argv_len); argv_len = nullptr;
	}
	argc = 0;
	cb = nullptr;
}
