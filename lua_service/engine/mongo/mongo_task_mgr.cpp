#include "mongo_task_mgr.h"
#include <thread>
#include <bsoncxx/builder/basic/document.hpp>
#include <mongocxx/instance.hpp>
#include <spdlog/fmt/fmt.h>
#include <mongocxx/exception/exception.hpp>
#include "iengine.h"

MongoTaskMgr::MongoTaskMgr()
{
	empty_doc = new bsoncxx::document::value(bsoncxx::builder::basic::document().extract());
}

MongoTaskMgr::~MongoTaskMgr()
{
	delete empty_doc; empty_doc = nullptr;
}

bool MongoTaskMgr::Start(int thread_num, const std::string &hosts, const std::string &db_name, const std::string usr, const std::string &pwd)
{
	bool ret = false;
	if (!m_is_running && thread_num > 0)
	{
		assert(nullptr == m_client_pool);

		try
		{
			std::string usr_pwd_str;
			if (usr.size() > 0 || pwd.size() > 0)
			{
				usr_pwd_str = fmt::format("{}:{}@", usr, pwd);
			}
			std::string poll_size_str = fmt::format("minPoolSize={}&maxPoolSize={}", thread_num, thread_num);
			m_mongo_uri = fmt::format("mongodb://{}{}/{}?{}", usr_pwd_str, hosts, db_name, poll_size_str);
			mongocxx::options::pool opt;
			m_client_pool = new mongocxx::pool(mongocxx::uri(m_mongo_uri), opt);
			auto xxx = m_client_pool->acquire();
		}
		catch (const mongocxx::exception& ex)
		{
			log_error("create mongo pool fail {} {}", ex.code().value(), ex.what());
			return false;
		}

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
	return ret;
}

void MongoTaskMgr::Stop()
{
	if (m_is_running)
	{
		m_is_running = false;
		for (int i = 0; i < m_thread_num; ++i)
		{
			ThreadEnv &td = m_thread_envs[i];
			td.is_exit = true;
		}
		for (int i = 0; i < m_thread_num; ++i)
		{
			ThreadEnv &td = m_thread_envs[i];
			td.cv.notify_one();
			td.thread_fd.join();
		}
		m_thread_num = 0;
		delete[] m_thread_envs; m_thread_envs = nullptr;

		while (!m_done_tasks.empty())
		{
			delete m_done_tasks.front();
			m_done_tasks.pop();
		}
		delete m_client_pool; m_client_pool = nullptr;
	}
}

void MongoTaskMgr::OnFrame()
{
	m_done_tasks_mtx.lock();
	std::queue<MongoTask *> tmp_done_task; tmp_done_task.swap(m_done_tasks);
	m_done_tasks_mtx.unlock();
	std::vector<MongoTask *> record_tos_task;
	while (!tmp_done_task.empty())
	{
		MongoTask *task = tmp_done_task.front();
		tmp_done_task.pop();
		task->HandleResult();
		delete task; task = nullptr;
	}
}

bool MongoTaskMgr::FindOne(uint32_t hash_code, const_str & db_name, const_str & coll_name, const_bson_doc & filter, const_bson_doc & opt, MongoTask::ResultCbFn cb_fn)
{
	bool ret = false;
	if (m_is_running && m_thread_num > 0)
	{
		MongoTask *task = new MongoTask(eMongoTask_FindOne, db_name, coll_name, filter, empty_doc->view(), opt, cb_fn);
		if (this->AddTaskToThread(hash_code, task))
		{
			ret = true;
		}
		else
		{
			delete task; task = nullptr;
		}
	}
	return ret;
}

bool MongoTaskMgr::InsertOne(uint32_t hash_code, const_str & db_name, const_str & coll_name, const_bson_doc & content, const_bson_doc & opt, MongoTask::ResultCbFn cb_fn)
{
	bool ret = false;
	if (m_is_running && m_thread_num > 0)
	{
		MongoTask *task = new MongoTask(eMongoTask_InsertOne, db_name, coll_name, empty_doc->view(), content, opt, cb_fn);
		if (this->AddTaskToThread(hash_code, task))
		{
			ret = true;
		}
		else
		{
			delete task; task = nullptr;
		}
	}
	return ret;
}

bool MongoTaskMgr::DeleteOne(uint32_t hash_code, const_str & db_name, const_str & coll_name, const_bson_doc & filter, const_bson_doc & opt, MongoTask::ResultCbFn cb_fn)
{
	bool ret = false;
	if (m_is_running && m_thread_num > 0)
	{
		MongoTask *task = new MongoTask(eMongoTask_DeleteOne, db_name, coll_name, filter, empty_doc->view(), opt, cb_fn);
		if (this->AddTaskToThread(hash_code, task))
		{
			ret = true;
		}
		else
		{
			delete task; task = nullptr;
		}
	}
	return ret;
}

bool MongoTaskMgr::UpdateOne(uint32_t hash_code, const_str & db_name, const_str & coll_name, const_bson_doc & filter, const_bson_doc & content, const_bson_doc & opt, MongoTask::ResultCbFn cb_fn)
{
	bool ret = false;
	if (m_is_running && m_thread_num > 0)
	{
		MongoTask *task = new MongoTask(eMongoTask_UpdateOne, db_name, coll_name, filter, content, opt, cb_fn);
		if (this->AddTaskToThread(hash_code, task))
		{
			ret = true;
		}
		else
		{
			delete task; task = nullptr;
		}
	}
	return ret;
}

bool MongoTaskMgr::ReplaceOne(uint32_t hash_code, const_str & db_name, const_str & coll_name, const_bson_doc & filter, const_bson_doc & content, const_bson_doc & opt, MongoTask::ResultCbFn cb_fn)
{
	bool ret = false;
	if (m_is_running && m_thread_num > 0)
	{
		MongoTask *task = new MongoTask(eMongoTask_ReplaceOne, db_name, coll_name, filter, content, opt, cb_fn);
		if (this->AddTaskToThread(hash_code, task))
		{
			ret = true;
		}
		else
		{
			delete task; task = nullptr;
		}
	}
	return ret;
}

void MongoTaskMgr::ThreadLoop(ThreadEnv * env)
{
	MongoTaskMgr *self = env->owner;
	while (!env->is_exit)
	{
		while (!env->is_exit)
		{
			boost::optional<mongocxx::pool::entry> opt_client = env->owner->m_client_pool->try_acquire();
			if (!opt_client)
			{
				continue;
			}
			if (!env->mtx.try_lock())
			{
				std::this_thread::yield();
				continue;
			}

			MongoTask *task = nullptr;
			if (!env->tasks.empty())
			{
				task = env->tasks.front();
				env->tasks.pop();
			}
			env->mtx.unlock();
			if (nullptr == task)
				break;
			task->Process(**opt_client);
			self->m_done_tasks_mtx.lock();
			self->m_done_tasks.push(task);
			self->m_done_tasks_mtx.unlock();
		}
		if (!env->is_exit)
		{
			std::unique_lock<std::mutex> cv_lock(env->mtx);
			env->cv.wait(cv_lock);
		}
	}
}

bool MongoTaskMgr::AddTaskToThread(uint32_t hash_code, MongoTask * task)
{
	if (!m_is_running || m_thread_num <= 0)
		return false;

	uint32_t woker_id = hash_code % m_thread_num;
	ThreadEnv &worker = m_thread_envs[woker_id];
	worker.mtx.lock();
	worker.tasks.push(task);
	worker.mtx.unlock();
	worker.cv.notify_one();
	return true;
}

MongoTaskMgr::ThreadEnv::~ThreadEnv()
{
	while (!tasks.empty())
	{
		delete tasks.front();
		tasks.pop();
	}
}
