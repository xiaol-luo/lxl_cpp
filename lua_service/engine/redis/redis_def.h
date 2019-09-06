#pragma once

#include <functional>
#include <string>
#include "hiredis.h"

struct RedisTask;
using RedisTaskCallback = std::function<void(RedisTask *redis_task)>;

struct RedisTask
{
	~RedisTask()
	{
		if (nullptr != reply)
		{
			freeReplyObject(reply);
			reply = nullptr;
		}
		cb = nullptr;
	}
	uint64_t task_id = 0;
	std::string cmd;
	RedisTaskCallback cb = nullptr;
	int error_num = 0;
	// std::string error_msg;
	redisReply *reply = nullptr;
};



