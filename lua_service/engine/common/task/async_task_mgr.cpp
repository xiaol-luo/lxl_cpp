#include "async_task_mgr.h"

AsyncTaskMgr::AsyncTaskMgr()
{

}

AsyncTaskMgr::~AsyncTaskMgr()
{
	this->Stop();
}

bool AsyncTaskMgr::Start(int thread_num)
{
	m_global_mtx.lock();

	bool ret = false;
	if (!m_is_running && thread_num > 0)
	{
		m_is_running = true;
		m_thread_num = thread_num;
		m_thread_envs = new ThreadEnv[thread_num];
		for (int i = 0; i < m_thread_num; ++i)
		{
			ThreadEnv &td = m_thread_envs[i];
			td.is_exit = false;
			td.owner = this;
			td.thread_fd = std::thread(ThreadLoop, &td);
		}
		ret = true;
	}
	m_global_mtx.unlock();
	return ret;
}

void AsyncTaskMgr::Stop()
{
	m_global_mtx.lock();
	if (m_is_running)
	{
		m_is_running = false;
		m_tasks_mtx.lock();
		while (!m_tasks.empty())
		{
			delete m_tasks.front();
			m_tasks.pop();
		}
		m_tasks_mtx.unlock();
		for (int i = 0; i < m_thread_num; ++i)
		{
			ThreadEnv &td = m_thread_envs[i];
			td.is_exit = true;
			m_tasks_cv.notify_all();
		}
		for (int i = 0; i < m_thread_num; ++i)
		{
			m_tasks_cv.notify_all();
			ThreadEnv &td = m_thread_envs[i];
			td.thread_fd.join();
		}
		m_thread_num = 0;
		delete[] m_thread_envs; m_thread_envs = nullptr;

		while (!m_done_tasks.empty())
		{
			delete m_done_tasks.front();
			m_done_tasks.pop();
		}
	}
	m_global_mtx.unlock();
}

bool AsyncTaskMgr::AddTask(TaskBase * task)
{
	if (nullptr == task)
		return false;
	
	m_tasks_mtx.lock();
	m_tasks.push(task);
	m_tasks_mtx.unlock();
	m_tasks_cv.notify_one();
	return true;
}

void AsyncTaskMgr::OnFrame()
{
	m_done_tasks_mtx.lock();
	std::queue<TaskBase *> tmp_done_task; tmp_done_task.swap(m_done_tasks);
	m_done_tasks_mtx.unlock();
	std::vector<TaskBase *> record_tos_task;
	while (!tmp_done_task.empty())
	{
		TaskBase *task = tmp_done_task.front();
		tmp_done_task.pop();
		task->HandleResult();
		delete task; task = nullptr;
	}
}

void AsyncTaskMgr::ThreadLoop(ThreadEnv *env)
{
	AsyncTaskMgr *self = env->owner;
	while (!env->is_exit)
	{
		while (!env->is_exit)
		{
			if (!self->m_tasks_mtx.try_lock())
			{
				std::this_thread::yield();
				continue;
			}

			TaskBase *task = nullptr;
			if (!self->m_tasks.empty())
			{
				task = self->m_tasks.front();
				self->m_tasks.pop();
			}
			self->m_tasks_mtx.unlock();
			if (nullptr == task)
				break;

			task->Process();
			self->m_done_tasks_mtx.lock();
			self->m_done_tasks.push(task);
			self->m_done_tasks_mtx.unlock();
		}

		if (!env->is_exit)
		{
			std::unique_lock<std::mutex> cv_lock(self->m_tasks_cv_mtx);
			self->m_tasks_cv.wait(cv_lock);
		}
	}
}
