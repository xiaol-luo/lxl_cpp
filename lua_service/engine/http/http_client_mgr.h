#pragma once

#include "net_handler/http_req_cnn.h"
#include "net_handler/net_handler_map.h"
#include <unordered_set>

class ServerLogic;

class HttpClientMgr
{
public:
	HttpClientMgr(ServerLogic *server_logic);
	~HttpClientMgr();

	uint64_t Get(const std::string &url, const std::unordered_map<std::string, std::string> *heads,
		HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent event_cb);
	uint64_t Delete(const std::string &url, const std::unordered_map<std::string, std::string> *heads,
		HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent event_cb);
	uint64_t Post(const std::string &url, const std::unordered_map<std::string, std::string> *heads, const std::string *content,
		HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent event_cb);
	uint64_t Put(const std::string &url, const std::unordered_map<std::string, std::string> *heads, const std::string *content,
		HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent event_cb);

	void Cancel(uint64_t async_id);

protected:
	uint64_t MethodHelp(HttpReqCnn::Method method, const std::string &url, const std::unordered_map<std::string, std::string> *heads, const std::string *content,
		HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent event_cb);

	ServerLogic * m_server_logic = nullptr;
	std::shared_ptr<NetHandlerMap<INetConnectHandler>> m_cnn_map = nullptr;

	struct CnnData
	{
		std::shared_ptr<HttpReqCnn> cnn = nullptr;
		HttpReqCnn::FnProcessRsp rsp_cb = nullptr;
		HttpReqCnn::FnProcessEvent event_cb = nullptr;
		int64_t async_id = 0;
	};
	std::unordered_map<uint64_t, CnnData> m_cnn_datas;

	void HandleHttpRsp(HttpReqCnn *cnn,
		const std::string &rsp_state, const std::unordered_map<std::string, std::string> &heads,
		std::string body, uint64_t body_len);

	enum eHttpAction 
	{
		eHttpAction_DnsQuery = HttpReqCnn::eActionType_Count + 100
	};
	void HandleHttpAction(HttpReqCnn *cnn, int action_type, int err_num);

	void DoDnsQuery(std::shared_ptr<HttpReqCnn> cnn, int err_num, std::string host, std::vector<std::string>& ips);
};