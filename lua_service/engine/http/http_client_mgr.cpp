#include "http_client_mgr.h"
#include "server_logic/ServerLogic.h"

HttpClientMgr::HttpClientMgr(ServerLogic *server_logic) : m_server_logic(server_logic)
{
	m_cnn_map = std::make_shared<NetHandlerMap<INetConnectHandler>>();
}

HttpClientMgr::~HttpClientMgr()
{
	m_cnn_map->Clear();
	m_cnn_map = nullptr;
}

uint64_t HttpClientMgr::Get(const std::string &url, const std::unordered_map<std::string, std::string> *heads,
	HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent event_cb)
{
	return MethodHelp(HttpReqCnn::Get, url, heads, nullptr, rsp_cb, event_cb);
}

uint64_t HttpClientMgr::Delete(const std::string & url, const std::unordered_map<std::string, std::string>* heads, HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent event_cb)
{
	return MethodHelp(HttpReqCnn::Delete, url, heads, nullptr, rsp_cb, event_cb);
}

uint64_t HttpClientMgr::Post(const std::string &url, const std::unordered_map<std::string, std::string> *heads, const std::string *content,
	HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent event_cb)
{
	return MethodHelp(HttpReqCnn::Post, url, heads, content, rsp_cb, event_cb);
}

uint64_t HttpClientMgr::Put(const std::string & url, const std::unordered_map<std::string, std::string>* heads, const std::string * content, HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent event_cb)
{
	return MethodHelp(HttpReqCnn::Put, url, heads, content, rsp_cb, event_cb);
}

void HttpClientMgr::Cancel(uint64_t async_id)
{
	auto it = m_cnn_datas.find(async_id);
	if (m_cnn_datas.end() != it)
	{
		CnnData &cnn_data = it->second;
		if (0 != cnn_data.async_id)
		{
			m_server_logic->GetNet()->CancelAsync(cnn_data.async_id);
		}
		m_cnn_datas.erase(it); it = m_cnn_datas.end();
	}
}

uint64_t HttpClientMgr::MethodHelp(HttpReqCnn::Method method, const std::string &url, const std::unordered_map<std::string, std::string> *heads, const std::string *content,
	HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent event_cb)
{
	if (url.size() <= 0 || nullptr == rsp_cb || method < 0 || method >= HttpReqCnn::Method_Count)
		return 0;

	std::shared_ptr<HttpReqCnn> cnn = std::make_shared<HttpReqCnn>(m_cnn_map);
	CnnData cnn_data;
	cnn_data.cnn = cnn;
	cnn_data.rsp_cb = rsp_cb;
	cnn_data.event_cb = event_cb;
	m_cnn_datas.insert(std::make_pair((uint64_t)cnn->GetPtr(), cnn_data));
	cnn->SetReqData(method, url, heads, content);
	cnn->SetRspCbFn(std::bind(&HttpClientMgr::HandleHttpRsp, this, std::placeholders::_1,
		std::placeholders::_2, std::placeholders::_3, std::placeholders::_4, std::placeholders::_5));
	cnn->SetEventCbFn(std::bind(&HttpClientMgr::HandleHttpAction, this, std::placeholders::_1,
		std::placeholders::_2, std::placeholders::_3));
	m_server_logic->GetDnsService()->QueryIpAsync(cnn->GetHost(),
		std::bind(&HttpClientMgr::DoDnsQuery, this, cnn,
			std::placeholders::_1, std::placeholders::_2, std::placeholders::_3));
	return (int64_t)cnn->GetPtr();
}

void HttpClientMgr::HandleHttpRsp(HttpReqCnn * cnn, const std::string &rsp_state, const std::unordered_map<std::string, std::string> &heads, std::string body, uint64_t body_len)
{
	uint64_t key = (uint64_t)cnn->GetPtr();
	auto it = m_cnn_datas.find(key);
	if (m_cnn_datas.end() != it)
	{
		CnnData &cnn_data = it->second;
		if (nullptr != cnn_data.rsp_cb)
		{
			cnn_data.rsp_cb(cnn, rsp_state, heads, body, body_len);
		}
	}
}

void HttpClientMgr::HandleHttpAction(HttpReqCnn *cnn, int action_type, int err_num)
{
	uint64_t key = (uint64_t)cnn->GetPtr();
	auto it = m_cnn_datas.find(key);
	if (m_cnn_datas.end() != it)
	{
		CnnData &cnn_data = it->second;
		if (nullptr != cnn_data.rsp_cb)
		{
			cnn_data.event_cb(cnn, (HttpReqCnn::eEventType)action_type, err_num);
		}

		if (0 != err_num || HttpReqCnn::eActionType_Close == action_type)
		{
			m_cnn_datas.erase(it);
			it = m_cnn_datas.end();
		}
	}
}

void HttpClientMgr::DoDnsQuery(std::shared_ptr<HttpReqCnn> cnn, int err_num, std::string host, std::vector<std::string>& ips)
{
	HttpReqCnn *cnn_ptr = dynamic_cast<HttpReqCnn *>(cnn->GetPtr());
	HandleHttpAction(cnn_ptr, eHttpAction_DnsQuery, err_num);

	if (0 == err_num && !ips.empty())
	{
		auto it = m_cnn_datas.find((uint64_t)cnn->GetPtr());
		if (m_cnn_datas.end() != it)
		{
			std::string ip = ips[0];
			CnnData &cnn_data = it->second;
			int64_t async_id = m_server_logic->GetNet()->ConnectAsync(ip, cnn->GetPort(), nullptr, cnn);
			cnn_data.async_id = async_id;
		}
	}
}
