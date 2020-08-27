#pragma once

#include "network/i_network_handler.h"
#include "buffer/net_buffer.h"
#include <string>
#include <unordered_map>
#include "net_handler_map.h"
#include <functional>

extern "C"
{
#include "http_parser/http_parser.h"
}

class HttpReqCnn;

class HttpReqCnn : public INetConnectHandler
{
public:
	enum Method
	{
		Get,
		Post,
		Put,
		Delete,
		Method_Count,
	};		
	using FnProcessRsp = std::function<void(
		HttpReqCnn * /*self*/,
		std::string /*rsp_state*/,
		const std::unordered_map<std::string, std::string> &/*heads*/,
		const std::string &/*body*/
		)>;
	enum eEventType
	{
		eActionType_Open,
		eActionType_Close,
		eActionType_Parse,
		eActionType_Count,
	};
	using FnProcessEvent = std::function<void(
		HttpReqCnn * /*self*/,
		eEventType /*error_type*/,
		int /*error_num*/
		)>;

	std::string Rsp_State_OK = "OK";
	std::string Rsp_State_Cnn_Open_Fail = "Connection_Open_Fail";
	std::string Rsp_State_Cnn_Break = "Connection_Break";
	std::string Rsp_State_Http_Parse_Fail = "Http_Parse_Fail";

public:
	HttpReqCnn(std::weak_ptr<NetHandlerMap<INetConnectHandler>> cnn_map);
	virtual ~HttpReqCnn();
	virtual void OnClose(int error_num) override;
	virtual void OnOpen(int error_num) override;
	virtual void OnRecvData(char *data, uint32_t len) override;
	bool SetReqData(Method method, const std::string &url, const std::unordered_map<std::string, std::string> *heads, const std::string *content);
	void SetRspCbFn(FnProcessRsp fn) { m_process_rsp_fn = fn; }
	void SetEventCbFn(FnProcessEvent fn) { m_process_event_fn = fn; }

	std::string GetHost() { return m_host; }
	std::string GetMethod() { return m_method; }
	int GetPort() { return m_port; }

protected:
	void ProcessRsp();

protected:
	// http parse callback
	static int on_message_begin(http_parser *parser);
	static int on_status(http_parser *parser, const char *at, size_t length);
	static int on_header_field(http_parser *parser, const char *at, size_t length);
	static int on_header_value(http_parser *parser, const char *at, size_t length);
	static int on_headers_complete(http_parser *parser);
	static int on_body(http_parser *parser, const char *at, size_t length);
	static int on_message_complete(http_parser *parser);
	static int on_chunk_header(http_parser *parser);
	static int on_chunk_complete(http_parser *parser);

protected:
	std::weak_ptr<NetHandlerMap<INetConnectHandler>> m_cnn_map;
	http_parser * m_parser = nullptr;
	http_parser_settings *m_parser_setting = nullptr;
	bool m_is_message_completed = false;
	bool m_already_execute_rsp_fn = false;
	FnProcessRsp m_process_rsp_fn = nullptr;
	FnProcessEvent m_process_event_fn = nullptr;
	NetBuffer *m_recv_buff = nullptr;

	struct KeyVal
	{
		void Reset() { key = std::string(); val = std::string(); }
		std::string key;
		std::string val;
	};
	enum EHandlingHead
	{
		EHandlingHead_None = 0,
		EHandlingHead_Key,
		EHandlingHead_Val,
	};
	std::string m_rsp_state; // 状态
	EHandlingHead m_handling_head = EHandlingHead_None;
	KeyVal m_req_head_kv; // 正在处理的请求头
	std::unordered_map<std::string, std::string> m_rsp_heads; // 请求头
	NetBuffer *m_rsp_body = nullptr; // 请求数据

	void CollectHead();
	NetBuffer *m_req_data_buff = nullptr;
	std::string m_host;
	std::string m_method;
	int m_port = 0;

	void ReleaseAll();
	void TryExecuteRspFn(const std::string &rsp_state, const std::string &extra_body_str);
};