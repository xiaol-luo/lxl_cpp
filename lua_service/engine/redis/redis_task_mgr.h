#pragma once

#include "hiredis.h"
#include "hircluster.h" 
#include "redis_def.h"
#include <regex>
#include <mutex>
#include <queue>

class RedisTaskMgr
{
public:
	RedisTaskMgr();
	~RedisTaskMgr();
	
	bool Start(bool is_cluster, const std::string &hosts, const std::string usr, const std::string &pwd, uint32_t thread_num,
		uint32_t connect_timeout_ms, uint32_t cmd_timeout_ms);
	void Stop();
	void OnFrame();


	uint64_t ExecuteCmd(uint64_t hash_code, RedisTaskCallback cb, std::string cmd);
	uint64_t ExecuteCmd(uint64_t hash_code, RedisTaskCallback cb, const char *format, ...);
	uint64_t ExecuteCmdArgv(uint64_t hash_code, RedisTaskCallback cb, std::vector<std::string> strs);
	uint64_t ExecuteCmdArgv(uint64_t hash_code, RedisTaskCallback cb, int argc, const char **argv, const size_t *argv_len);
	uint64_t ExecuteCmdBinFormat(uint64_t hash_code, RedisTaskCallback cb, std::string format, std::vector<std::string> strs);

private:
	bool m_is_running = false;
	uint64_t m_last_id = 0;
	bool m_is_cluster = false;
	std::string m_hosts;
	std::string m_usr;
	std::string m_pwd;
	uint32_t m_connect_timeout_ms = 5000;
	uint32_t m_cmd_timeout_ms = 10000;

	std::mutex m_done_tasks_mtx;
	std::queue<RedisTask *> m_done_tasks;

	struct ThreadEnv
	{
		ThreadEnv() {}
		~ThreadEnv();

		std::thread thread_fd;
		bool is_exit = false;
		std::mutex mtx;
		std::condition_variable cv;
		std::queue<RedisTask *> tasks;
		RedisTaskMgr *owner = nullptr;

		bool SetupCtx();
		redisContext *redis_ctx = nullptr;
		redisClusterContext *redis_cluster_ctx = nullptr;
	};
	uint32_t m_thread_num = 0;
	ThreadEnv *m_thread_envs = nullptr;
	static void ThreadLoop(ThreadEnv *env);
	bool AddTaskToThread(uint64_t hash_code, RedisTask *task);
	uint64_t NextId();
};

