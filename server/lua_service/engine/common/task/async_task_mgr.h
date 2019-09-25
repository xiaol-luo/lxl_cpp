#pragma once

#include <stdint.h>
#include <thread>
#include <mutex>
#include <condition_variable>
#include "task_base.h"
#include <queue>

class AsyncTaskMgr
{
public:
	AsyncTaskMgr();
	~AsyncTaskMgr();
	
	bool Start(int thread_num);
	void Stop();
	bool AddTask(TaskBase *task);
	void OnFrame();

private:
	std::mutex m_tasks_cv_mtx;
	std::condition_variable m_tasks_cv;
	std::mutex m_tasks_mtx;
	std::queue<TaskBase *> m_tasks;

	std::mutex m_done_tasks_mtx;
	std::queue<TaskBase *> m_done_tasks;

	std::mutex m_global_mtx;
	bool m_is_running = false;

private:
	struct ThreadEnv
	{
		std::thread thread_fd;
		bool is_exit = false;
		AsyncTaskMgr *owner = nullptr;
	};
	uint32_t m_thread_num = 0;
	ThreadEnv *m_thread_envs = nullptr;
	static void ThreadLoop(ThreadEnv *data);
};