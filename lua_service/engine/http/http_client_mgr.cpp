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

int64_t HttpClientMgr::Get(std::string url, HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent err_cb)
{
	return this->Get(url, std::unordered_map<std::string, std::string>(), rsp_cb, err_cb);
}

int64_t HttpClientMgr::Get(std::string url, std::unordered_map<std::string, std::string> heads, HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent event_cb)
{
	if (url.size() <= 0 || nullptr == rsp_cb)
		return 0;

	std::shared_ptr<HttpReqCnn> cnn = std::make_shared<HttpReqCnn>(m_cnn_map);
	CnnData cnn_data;
	cnn_data.cnn = cnn;
	cnn_data.rsp_cb = rsp_cb;
	cnn_data.event_cb = event_cb;
	m_cnn_datas.insert(std::make_pair((uint64_t)cnn->GetPtr(), cnn_data));
	cnn->SetReqData(true, url, heads, "");
	cnn->SetRspCbFn(std::bind(&HttpClientMgr::HandleHttpRsp, this, std::placeholders::_1,
		std::placeholders::_2, std::placeholders::_3, std::placeholders::_4, std::placeholders::_5));
	cnn->SetEventCbFn(std::bind(&HttpClientMgr::HandleHttpAction, this, std::placeholders::_1,
		std::placeholders::_2, std::placeholders::_3));
	int64_t async_id = m_server_logic->GetNet()->ConnectAsync(cnn->GetIp(), cnn->GetPort(), nullptr, cnn);
	return async_id;
}

int64_t HttpClientMgr::Post(std::string url, std::unordered_map<std::string, std::string> heads, std::string content, HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent event_cb)
{
	if (url.size() <= 0 || nullptr == rsp_cb)
		return 0;

	std::shared_ptr<HttpReqCnn> cnn = std::make_shared<HttpReqCnn>(m_cnn_map);
	CnnData cnn_data;
	cnn_data.cnn = cnn;
	cnn_data.rsp_cb = rsp_cb;
	cnn_data.event_cb = event_cb;
	m_cnn_datas.insert(std::make_pair((uint64_t)cnn->GetPtr(), cnn_data));
	cnn->SetReqData(true, url, heads, content);
	cnn->SetRspCbFn(std::bind(&HttpClientMgr::HandleHttpRsp, this, std::placeholders::_1, 
		std::placeholders::_2, std::placeholders::_3, std::placeholders::_4, std::placeholders::_5));
	cnn->SetEventCbFn(std::bind(&HttpClientMgr::HandleHttpAction, this, std::placeholders::_1, 
		std::placeholders::_2, std::placeholders::_3));
	int64_t async_id = m_server_logic->GetNet()->ConnectAsync(cnn->GetIp(), cnn->GetPort(), nullptr, cnn);
	return async_id;
}

int64_t HttpClientMgr::Post(std::string url, HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent err_cb)
{
	return this->Post(url, std::unordered_map<std::string, std::string>(), "", rsp_cb, err_cb);
}

void HttpClientMgr::Cancel(int64_t async_id)
{
	m_server_logic->GetNet()->CancelAsync(async_id);
}


void HttpClientMgr::HandleHttpRsp(HttpReqCnn * cnn, std::string url, std::unordered_map<std::string, std::string> heads, std::string body, uint64_t body_len)
{
	uint64_t key = (uint64_t)cnn->GetPtr();
	auto it = m_cnn_datas.find(key);
	if (m_cnn_datas.end() != it)
	{
		CnnData &cnn_data = it->second;
		if (nullptr != cnn_data.rsp_cb)
		{
			cnn_data.rsp_cb(cnn, url, heads, body, body_len);
		}
	}
}

void HttpClientMgr::HandleHttpAction(HttpReqCnn *cnn, HttpReqCnn::eEventType action_type, int err_num)
{
	uint64_t key = (uint64_t)cnn->GetPtr();
	auto it = m_cnn_datas.find(key);
	if (m_cnn_datas.end() != it)
	{
		CnnData &cnn_data = it->second;
		if (nullptr != cnn_data.rsp_cb)
		{
			cnn_data.event_cb(cnn, action_type, err_num);
		}

		if (HttpReqCnn::eActionType_Close == action_type ||
			(HttpReqCnn::eActionType_Open == action_type && 0 != err_num))
		{
			m_cnn_datas.erase(it);
			it = m_cnn_datas.end();
		}
	}
}