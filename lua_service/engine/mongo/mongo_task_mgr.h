#pragma once

#include "mongo_task.h"
#include <queue>
#include <mutex>
#include <condition_variable>

class MongoTaskMgr
{
public:
	MongoTaskMgr();
	~MongoTaskMgr();

	bool Start(int thread_num);
	void Stop();
	void OnFrame();

private:
	bool m_is_running = false;

	std::queue<MongoTask *> m_done_task;
	std::mutex m_done_task_mtx;

	struct ThreadEnv
	{
		std::thread thread_fd;
		bool is_exit = false;
		std::mutex mtx;
		std::condition_variable cv;
		std::queue<MongoTask *> m_tasks;
		MongoTaskMgr *owner = nullptr;
	};
	uint32_t m_thread_num = 0;
	ThreadEnv *m_thread_envs = nullptr;
	static void ThreadLoop(ThreadEnv *data);
};
