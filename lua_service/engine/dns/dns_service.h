#pragma once

#include "common/task/task_base.h"
#include "common/task/async_task_mgr.h"
#include "dns_def.h"
#include <string>
#include <functional>
#include <vector>

using DnsQueryIpCallback = std::function<void(int /*err_num*/, std::string /*host*/, std::vector<std::string>& /*ips*/)>;

class DnsService
{
public:
	DnsService();
	~DnsService();

	bool Start();
	void Stop();
	void OnFrame();

	int QueryIp(std::string host, std::vector<std::string> *out_ips);
	void QueryIpAsync(std::string host, DnsQueryIpCallback cb);

private:
	class QueryTask : public TaskBase
	{
		friend DnsService;
	public:
		QueryTask(std::string host, DnsQueryIpCallback cb);
		virtual void Process();
		virtual void HandleResult();

		std::string host_;
		DnsQueryIpCallback cb_ = nullptr;
		int err_num_ = 0;
		std::vector<std::string > ips_;
	};
	const static int TASK_MGR_THEAD_NUM = 2;
	AsyncTaskMgr m_task_mgr;
};