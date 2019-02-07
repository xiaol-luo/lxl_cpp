#include "dns_service.h"

DnsService::DnsService()
{
}

DnsService::~DnsService()
{
	m_task_mgr.Stop();
}

bool DnsService::Start()
{
	return m_task_mgr.Start(TASK_MGR_THEAD_NUM);
}

void DnsService::Stop()
{
	m_task_mgr.Stop();
}

void DnsService::OnFrame()
{
	m_task_mgr.OnFrame();
}

int DnsService::QueryIp(std::string host, std::vector<std::string>* out_ips)
{
	QueryTask task(host, nullptr);
	task.Process();
	if (nullptr != out_ips)
	{
		*out_ips = task.ips_;
	}
	return task.err_num_;
}

void DnsService::QueryIpAsync(std::string host, DnsQueryIpCallback cb)
{
	QueryTask *task = new QueryTask(host, cb);
	m_task_mgr.AddTask(task);
}

DnsService::QueryTask::QueryTask(std::string host, DnsQueryIpCallback cb)
{
	host_ = host;
	cb_ = cb;
}

void DnsService::QueryTask::Process()
{
	{
		hostent *ht = gethostbyname(host_.c_str());
		if (nullptr == ht)
		{
#ifdef WIN32
			err_num_ = -1;
#else
			err_num_ = errno;
#endif // WIN32

		}
		else
		{
			ips_.clear();
			char buff[64];
			for (int i = 0; ht->h_addr_list[i]; ++i)
			{
				inet_ntop(ht->h_addrtype, (void*)ht->h_addr_list[i], buff, sizeof(buff));
				buff[sizeof(buff) - 1] = '\0';
				ips_.push_back(std::string(buff, sizeof(buff)));
			}
		}
	}
}

void DnsService::QueryTask::HandleResult()
{
	if (nullptr != cb_)
	{
		cb_(err_num_, host_, ips_);
	}
}
