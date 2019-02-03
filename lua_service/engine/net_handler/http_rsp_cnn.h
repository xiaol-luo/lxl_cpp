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

class HttpRspCnn;

class HttpRspCnn : public INetConnectHandler
{
public:
	using FnProcessReq = std::function<bool(HttpRspCnn * /*self*/,
		uint32_t /*get/post*/,
		std::string /*url*/,
		std::unordered_map<std::string, std::string> /*heads*/,
		std::string /*body*/,
		uint64_t /*body_len*/
		)>;
	enum eEventType
	{
		eActionType_Open,
		eActionType_Close,
		eActionType_Parse,
	};
	using FnProcessEvent = std::function<void(
		HttpRspCnn * /*self*/,
		eEventType /*err_type*/,
		int /*err_num*/
		)>;

public:
	HttpRspCnn(std::weak_ptr<NetHandlerMap<INetConnectHandler>> cnn_map);
	virtual ~HttpRspCnn();
	virtual void OnClose(int err_num) override;
	virtual void OnOpen(int err_num) override;
	virtual void OnRecvData(char *data, uint32_t len) override;

	void SetReqCbFn(FnProcessReq fn) { m_process_req_fn = fn; }
	void SetEventCbFn(FnProcessEvent fn) { m_process_event_fn = fn; }

protected:
	void ProcessReq();

protected:
	// http parse callback
	static int on_message_begin(http_parser *parser);
	static int on_url(http_parser *parser, const char *at, size_t length);
	static int on_header_field(http_parser *parser, const char *at, size_t length);
	static int on_header_value(http_parser *parser, const char *at, size_t length);
	static int on_headers_complete(http_parser *parser);
	static int on_body(http_parser *parser, const char *at, size_t length);
	static int on_message_complete(http_parser *parser);
	static int on_chunk_header(http_parser *parser);
	static int on_chunk_complete(http_parser *parser);

protected:
	FnProcessReq m_process_req_fn = nullptr;
	FnProcessEvent m_process_event_fn = nullptr;
	std::weak_ptr<NetHandlerMap<INetConnectHandler>> m_cnn_map;
	http_parser * m_parser = nullptr;
	http_parser_settings *m_parser_setting = nullptr;
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
	std::string m_req_url; // 请求行
	EHandlingHead m_handling_head = EHandlingHead_None;
	KeyVal m_req_head_kv; // 正在处理的请求头
	std::unordered_map<std::string, std::string> m_req_heads; // 请求头
	NetBuffer *m_req_body = nullptr; // 请求数据

	void CollectHead();
};