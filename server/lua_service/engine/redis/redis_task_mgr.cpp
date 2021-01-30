#include "redis_task_mgr.h"
#include <assert.h>
#include "iengine.h"

extern "C" int __redisAppendCommand(redisContext *c, const char *cmd, size_t len);

RedisTaskMgr::RedisTaskMgr()
{
}

RedisTaskMgr::~RedisTaskMgr()
{
	this->Stop();
}

bool RedisTaskMgr::Start(bool is_cluster, const std::string & hosts, const std::string & pwd,
	uint32_t thread_num, uint32_t connect_timeout_ms, uint32_t cmd_timeout_ms)
{
	if (m_is_running)
		return false;

	m_is_cluster = is_cluster;
	m_hosts = hosts; 
	assert(m_hosts.size() > 0);
	m_pwd = pwd;
	m_thread_num = thread_num;
	assert(m_thread_num > 0);
	m_connect_timeout_ms = connect_timeout_ms;
	m_cmd_timeout_ms = cmd_timeout_ms;

	bool all_ok = true;
	m_thread_envs = new ThreadEnv[m_thread_num];
	for (uint32_t i = 0; i < m_thread_num; ++i)
	{
		ThreadEnv &td = m_thread_envs[i];
		td.is_exit = false;
		td.owner = this;
		if (!td.SetupCtx())
		{
			all_ok = false;
			break;
		}
	}
	if (!all_ok)
	{
		this->Stop();
	}
	else
	{
		for (uint32_t i = 0; i < m_thread_num; ++i)
		{
			ThreadEnv &td = m_thread_envs[i];
			td.thread_fd = std::thread(ThreadLoop, &td);
		}
	}
	if (all_ok)
	{
		m_is_running = true;
	}
	return all_ok;
}

void RedisTaskMgr::Stop()
{
	if (m_is_running)
	{
		m_is_running = false;
		for (uint32_t i = 0; i < m_thread_num; ++i)
		{
			ThreadEnv &td = m_thread_envs[i];
			td.is_exit = true;
		}
		for (uint32_t i = 0; i < m_thread_num; ++i)
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
	}
}

void RedisTaskMgr::OnFrame()
{
	m_done_tasks_mtx.lock();
	std::queue<RedisTask *> tmp_done_task; tmp_done_task.swap(m_done_tasks);
	m_done_tasks_mtx.unlock();
	while (!tmp_done_task.empty())
	{
		RedisTask *task = tmp_done_task.front();
		tmp_done_task.pop();

		if (task->cb)
		{
			task->cb(task);
		}
		delete task; task = nullptr;
	}
}

uint64_t RedisTaskMgr::ExecuteCmd(uint64_t hash_code, RedisTaskCallback cb, std::string cmd)
{
	return this->ExecuteCmd(hash_code, cb, cmd.c_str());
}

uint64_t RedisTaskMgr::ExecuteCmd(uint64_t hash_code, RedisTaskCallback cb, const char * format, ...)
{
	if (nullptr == format)
		return 0;

	uint64_t task_id = this->NextId();
	RedisTask *task = new RedisTask();
	task->task_id = task_id;
	task->cb = cb;

	va_list ap;
	va_start(ap, format);
	task->cmd_len = redisvFormatCommand(&task->cmd, format, ap);
	va_end(ap);
	
	if (task->cmd_len == -1)
	{
		task->error_num = REDIS_ERR_OOM;
		task->error_msg = "Out of memory";
	}
	else if (task->cmd_len == -2)
	{
		task->error_num = REDIS_ERR_OTHER;
		task->error_msg = "Invalid format string";
	}
	this->AddTaskToThread(hash_code, task);
	return task_id;
}

uint64_t RedisTaskMgr::ExecuteCmdArgv(uint64_t hash_code, RedisTaskCallback cb, std::vector<std::string> strs)
{
	if (strs.size() <= 0)
		return 0;

	size_t str_size = strs.size();
	const char **argv = (const char **)malloc(sizeof(char *) * str_size);
	size_t *argv_len = (size_t *)malloc(sizeof(size_t *) * str_size);
	for (size_t i = 0; i < str_size; ++i)
	{
		argv[i] = strs[i].data();
		argv_len[i] = strs[i].size();
	}
	uint64_t task_id = this->ExecuteCmdArgv(hash_code, cb, str_size, argv, argv_len);
	free(argv); argv = nullptr;
	free(argv_len); argv_len = nullptr;
	return task_id;
}

uint64_t RedisTaskMgr::ExecuteCmdArgv(uint64_t hash_code, RedisTaskCallback cb, int argc, const char ** argv, const size_t * argv_len)
{
	if (argc <= 0 || nullptr == argv || nullptr == argv_len)
		return 0;

	uint64_t task_id = this->NextId();
	RedisTask *task = new RedisTask();
	task->task_id = task_id;
	task->cb = cb;
	task->cmd_len = redisFormatSdsCommandArgv(&task->cmd, argc, argv, argv_len);
	if (task->cmd_len == -1)
	{
		task->error_num = REDIS_ERR_OOM;
		task->error_msg = "Out of memory";
	}
	this->AddTaskToThread(hash_code, task);
	return task_id;
}

uint64_t RedisTaskMgr::ExecuteCmdBinFormat(uint64_t hc, RedisTaskCallback cb, std::string fm, std::vector<std::string> s)
{
#define p_l(str) str.data(), str.size()
	// format ֻ֧��%b
	switch (s.size())
	{
	case 0: return this->ExecuteCmd(hc, cb, fm.c_str());
	case 1: return this->ExecuteCmd(hc, cb, fm.c_str(), p_l(s[0]));
	case 2: return this->ExecuteCmd(hc, cb, fm.c_str(), p_l(s[0]), p_l(s[1]));
	case 3: return this->ExecuteCmd(hc, cb, fm.c_str(), p_l(s[0]), p_l(s[1]), p_l(s[2]));
	case 4: return this->ExecuteCmd(hc, cb, fm.c_str(), p_l(s[0]), p_l(s[1]), p_l(s[2]), p_l(s[3]));
	case 5: return this->ExecuteCmd(hc, cb, fm.c_str(), p_l(s[0]), p_l(s[1]), p_l(s[2]), p_l(s[3]), p_l(s[4]));
	case 6: return this->ExecuteCmd(hc, cb, fm.c_str(), p_l(s[0]), p_l(s[1]), p_l(s[2]), p_l(s[3]), p_l(s[4]), p_l(s[5]));
	case 7: return this->ExecuteCmd(hc, cb, fm.c_str(), p_l(s[0]), p_l(s[1]), p_l(s[2]), p_l(s[3]), p_l(s[4]), p_l(s[5]), p_l(s[6]));
	case 8: return this->ExecuteCmd(hc, cb, fm.c_str(), p_l(s[0]), p_l(s[1]), p_l(s[2]), p_l(s[3]), p_l(s[4]), p_l(s[5]), p_l(s[6]), p_l(s[7]));
	case 9: return this->ExecuteCmd(hc, cb, fm.c_str(), p_l(s[0]), p_l(s[1]), p_l(s[2]), p_l(s[3]), p_l(s[4]), p_l(s[5]), p_l(s[6]), p_l(s[7]), p_l(s[8]));
	case 10: return this->ExecuteCmd(hc, cb, fm.c_str(), p_l(s[0]), p_l(s[1]), p_l(s[2]), p_l(s[3]), p_l(s[4]), p_l(s[5]), p_l(s[6]), p_l(s[7]), p_l(s[8]), p_l(s[9]));
	}

	log_error("RedisTaskMgr::ExecuteCmdBinFormat too many params, max=10, count={}", s.size());
	return 0;
#undef p_l
}

bool RedisTaskMgr::AddTaskToThread(uint64_t hash_code, RedisTask * task)
{
	if (!m_is_running || m_thread_num <= 0)
		return false;

	uint32_t worker_id = hash_code % m_thread_num;
	ThreadEnv &worker = m_thread_envs[worker_id];
	worker.mtx.lock();
	worker.tasks.push(task);
	worker.mtx.unlock();
	worker.cv.notify_one();
	return true;
}

uint64_t RedisTaskMgr::NextId()
{
	++ m_last_id;
	return m_last_id;
}

void RedisTaskMgr::ThreadLoop(ThreadEnv * env)
{
	RedisTaskMgr *self = env->owner;
	bool is_cluster = self->m_is_cluster;
	bool is_ctx_error = true;

	while (!env->is_exit)
	{
		while (!env->is_exit && !env->tasks.empty())
		{
			if (is_ctx_error)
			{
				if (!env->SetupCtx())
				{
					continue;
				}
				is_ctx_error = false;
			}

			if (!env->mtx.try_lock())
			{
				std::this_thread::yield();
				continue;
			}

			RedisTask *task = nullptr;
			if (!env->tasks.empty())
			{
				task = env->tasks.front();
				env->tasks.pop();
			}
			env->mtx.unlock();
			if (nullptr == task)
				break;

			if (REDIS_OK == task->error_num)
			{
				redisReply *reply = nullptr;
				if (is_cluster)
				{
					reply = (redisReply *)redisClusterFormattedCommand(env->redis_cluster_ctx, task->cmd, task->cmd_len);
					task->reply = reply;
					if (nullptr == reply || 0 != env->redis_cluster_ctx->err) // ??
					{
						task->error_num = env->redis_cluster_ctx->err;
						task->error_msg = env->redis_cluster_ctx->errstr;
						is_ctx_error = true;
					}
				}
				else
				{
					if (REDIS_OK == __redisAppendCommand(env->redis_ctx, task->cmd, task->cmd_len))
					{
						redisGetReply(env->redis_ctx, (void **)&reply);
					}

					// reply = (redisReply *)redisCommandArgv(env->redis_ctx, task->argc, (const char **)task->argv, task->argv_len);
					task->reply = reply;
					if (nullptr == reply || 0 == env->redis_ctx->err)
					{
						task->error_num = env->redis_ctx->err;
						task->error_msg = env->redis_ctx->errstr;
						is_ctx_error = true;
					}
				}
				if (nullptr != reply)
				{
					if (REDIS_REPLY_ERROR == reply->type)
					{
						task->error_num = REDIS_ERR_OTHER;
						task->error_msg = reply->str;
					}
				}
			}
			else
			{
				// ��ִ��ExecuteCmd��ʱ���Ѿ���⵽����Ϊ�˱����첽��Ϊ���Ѵ���ŵ��������ص�
			}

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

bool RedisTaskMgr::ThreadEnv::SetupCtx()
{
	if (redis_cluster_ctx)
	{
		redisClusterFree(redis_cluster_ctx);
		redis_cluster_ctx = nullptr;
	}
	if (redis_ctx)
	{
		redisFree(redis_ctx);
		redis_ctx = nullptr;
	}

	timeval cnn_tv;
	cnn_tv.tv_sec = this->owner->m_connect_timeout_ms / 1000;
	cnn_tv.tv_usec = this->owner->m_connect_timeout_ms % 1000 * 1000;
	timeval cmd_tv;
	cmd_tv.tv_sec = this->owner->m_cmd_timeout_ms / 1000;
	cmd_tv.tv_usec = this->owner->m_cmd_timeout_ms % 1000;
	if (this->owner->m_is_cluster)
	{

		this->redis_cluster_ctx = redisClusterContextInit();
		{
			if (strlen(this->owner->m_pwd.c_str()) > 0)
			{
				redisClusterSetOptionAuth(this->redis_cluster_ctx, this->owner->m_pwd.c_str());
			}
			redisClusterSetOptionRouteUseSlots(this->redis_cluster_ctx);
			redisClusterSetOptionConnectBlock(this->redis_cluster_ctx);
			redisClusterSetOptionConnectTimeout(this->redis_cluster_ctx, cnn_tv);
			redisClusterSetOptionTimeout(this->redis_cluster_ctx, cmd_tv);
			if (REDIS_OK != redisClusterSetOptionAddNodes(this->redis_cluster_ctx, this->owner->m_hosts.c_str()))
			{
				log_error("RedisTaskMgr::ThreadEnv::SetupCtx redisClusterSetOptionAddNodes error {}", this->redis_cluster_ctx->errstr);
				return false;
			}
			if (REDIS_OK != redisClusterConnect2(this->redis_cluster_ctx))
			{
				log_error("RedisTaskMgr::ThreadEnv::SetupCtx redisClusterConnect2 error {}", this->redis_cluster_ctx->errstr);
				return false;
			}
		}
		if (REDIS_OK == this->redis_cluster_ctx->err)
		{
			redisClusterSetOptionTimeout(this->redis_cluster_ctx, cmd_tv);
			if (this->owner->m_pwd.size() > 0)
			{
				redisReply *reply = (redisReply *)redisClusterCommand(this->redis_cluster_ctx, "auth %s", this->owner->m_pwd.c_str());
				if (nullptr == reply || 0 != strcmp(reply->str, "OK"))
				{
					log_error("RedisTaskMgr::ThreadEnv::SetupCtx redisClusterCommand to auth error {}", this->redis_cluster_ctx->errstr);
					return false;
				}
			}
			return true;
		}
		return false;
	}
	else
	{
		std::string match_pattern_str = R"raw(([\S]+):([0-9]+))raw";
		std::regex match_pattern(match_pattern_str, std::regex::icase);
		std::smatch match_ret;
		bool is_match = regex_match(this->owner->m_hosts, match_ret, match_pattern);
		if (!is_match)
		{
			log_error("RedisTaskMgr::ThreadEnv::SetupCtx regex_match hosts fail {}", this->owner->m_hosts);
			return false;
		}

		int port = 0;
		std::string port_str = match_ret[2].str();
		if (port_str.size() <= 0)
			return false;
		try { port = std::stoi(port_str); }
		catch (std::exception)
		{
			log_error("RedisTaskMgr::ThreadEnv::SetupCtx convert port fail, port_str: {}", port_str);
			return false;
		}

		std::string ip = match_ret[1].str();
		if (ip.size() <= 0)
		{
			log_error("RedisTaskMgr::ThreadEnv::SetupCtx no valid ip, ip: {}", ip);
			return false;
		}
		this->redis_ctx = redisConnectWithTimeout(ip.c_str(), port, cnn_tv);
		if (0 == this->redis_ctx->err)
		{
			redisSetTimeout(this->redis_ctx, cmd_tv);
			if (strlen(this->owner->m_pwd.c_str()) > 0)
			{
				redisReply *reply = (redisReply *)redisCommand(this->redis_ctx, "auth %s", this->owner->m_pwd.c_str());
				if (nullptr == reply || 0 != strcmp(reply->str, "OK"))
				{
					log_error("RedisTaskMgr::ThreadEnv::SetupCtx redisCommand to auth error {}", this->redis_ctx->errstr);
					return false;
				}
			}
			return true;
		}
		return false;
	}
}

RedisTaskMgr::ThreadEnv::~ThreadEnv()
{
	while (!tasks.empty())
	{
		delete tasks.front();
		tasks.pop();
	}
	if (redis_cluster_ctx)
	{
		redisClusterFree(redis_cluster_ctx);
		redis_cluster_ctx = nullptr;
	}
	if (redis_ctx)
	{
		redisFree(redis_ctx);
		redis_ctx = nullptr;
	}
}
