#pragma once

#include "net_handler/http_req_cnn.h"
#include "net_handler/net_handler_map.h"

class ServerLogic;

class HttpClientMgr
{
public:
	HttpClientMgr(ServerLogic *server_logic);
	~HttpClientMgr();

	int64_t Get(std::string url, HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent err_cb);
	int64_t Get(std::string url, std::unordered_map<std::string, std::string> heads, 
		HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent err_cb);
	int64_t Post(std::string url, std::unordered_map<std::string, std::string> heads, std::string content,
		HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent err_cb);
	int64_t Post(std::string url, HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent err_cb);
	void Cancel(int64_t async_id);

protected:
	ServerLogic * m_server_logic = nullptr;
	std::shared_ptr<NetHandlerMap<INetConnectHandler>> m_cnn_map = nullptr;

	/*
	void HandleHttpRsp(HttpReqCnn *cnn,
		std::string url, std::unordered_map<std::string, std::string> heads,
		std::string body, uint64_t body_len);
	void HandleHttpErr(HttpReqCnn *cnn, HttpReqCnn::eErrType err_type, int err_num);
	*/
};