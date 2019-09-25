#pragma once

#include <functional>
#include <string>
#include "hiredis.h"

struct RedisTask;
using RedisTaskCallback = std::function<void(RedisTask *redis_task)>;

struct RedisTask
{
	RedisTask() {}
	~RedisTask();

	uint64_t task_id = 0;
	int argc = 0;
	char **argv = nullptr;
	size_t * argv_len = nullptr;
	RedisTaskCallback cb = nullptr;

	char *cmd = nullptr;
	size_t cmd_len = 0;

	int error_num = 0;
	std::string error_msg;
	redisReply *reply = nullptr;
};



