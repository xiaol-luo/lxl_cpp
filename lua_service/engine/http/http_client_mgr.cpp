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

int64_t HttpClientMgr::Get(std::string url, std::unordered_map<std::string, std::string> heads, HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent err_cb)
{
	if (url.size() <= 0 || nullptr == rsp_cb)
		return 0;

	std::shared_ptr<HttpReqCnn> cnn = std::make_shared<HttpReqCnn>(m_cnn_map);
	cnn->SetReqData(true, url, heads, "");
	cnn->SetRspCbFn(rsp_cb);
	cnn->SetEventCbFn(err_cb);
	int64_t async_id = m_server_logic->GetNet()->ConnectAsync(cnn->GetIp(), cnn->GetPort(), nullptr, cnn);
	return async_id;
}

int64_t HttpClientMgr::Post(std::string url, std::unordered_map<std::string, std::string> heads, std::string content, HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent err_cb)
{
	if (url.size() <= 0 || nullptr == rsp_cb)
		return 0;

	std::shared_ptr<HttpReqCnn> cnn = std::make_shared<HttpReqCnn>(m_cnn_map);
	cnn->SetReqData(true, url, heads, content);
	cnn->SetRspCbFn(rsp_cb);
	cnn->SetEventCbFn(err_cb);
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

/*
void HttpClientMgr::HandleHttpRsp(HttpReqCnn * cnn, std::string url, std::unordered_map<std::string, std::string> heads, std::string body, uint64_t body_len)
{
}

void HttpClientMgr::HandleHttpErr(HttpReqCnn * cnn, HttpReqCnn::eErrType err_type, int err_num)
{
}
*/