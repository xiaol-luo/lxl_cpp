#pragma once

#include "mongo_def.h"
#include <queue>
#include <mutex>
#include <condition_variable>

class MongoTaskMgr
{
public: 
	using const_str = const std::string;
	using const_bson_doc = const bsoncxx::document::view_or_value;
public:
	MongoTaskMgr();
	~MongoTaskMgr();

	bool Start(int thread_num);
	void Stop();
	void OnFrame();

	bool FindOne(uint32_t hash_code, const_str &db_name, const_str &coll_name, const_bson_doc &filter, const_bson_doc &opt, MongoTask::ResultCbFn cb_fn);

private:
	std::mutex m_global_mtx;
	bool m_is_running = false;

	std::mutex m_done_tasks_mtx;
	std::queue<MongoTask *> m_done_tasks;

	struct ThreadEnv
	{
		ThreadEnv() {}
		~ThreadEnv();

		std::thread thread_fd;
		bool is_exit = false;
		std::mutex mtx;
		std::condition_variable cv;
		std::queue<MongoTask *> tasks;
		MongoTaskMgr *owner = nullptr;
	};
	uint32_t m_thread_num = 0;
	ThreadEnv *m_thread_envs = nullptr;
	static void ThreadLoop(ThreadEnv *data);
	bool AddTaskToThread(uint32_t hash_code, MongoTask *task);

	static bsoncxx::builder::basic::document BSONCXX_EMPTY_DOC;
};
