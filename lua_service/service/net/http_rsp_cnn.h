#pragma once

#include "network/i_network_handler.h"
#include "buffer/net_buffer.h"
#include <string>
#include <unordered_map>

extern "C" 
{
	#include "http_parser/http_parser.h"
}

class HttpRspCnnMgr;

class HttpRspCnn : public INetConnectHander
{
public:
	HttpRspCnn(std::weak_ptr<HttpRspCnnMgr> mgr);
	virtual ~HttpRspCnn();
	virtual void OnClose(int err_num) override;
	virtual void OnOpen(int err_num) override;
	virtual void OnRecvData(char *data, uint32_t len) override;

protected:
	std::weak_ptr<HttpRspCnnMgr> m_mgr;
	NetBuffer *m_buff = nullptr;
	http_parser * m_parser = nullptr;
	http_parser_settings *m_parser_setting = nullptr;
	std::string m_handling_head_field;
	std::unordered_map<std::string, std::string> m_heads;

protected:
	// http parse callback
	static int on_message_begin(http_parser *parser);
	static int on_url(http_parser *parser, const char *at, size_t length);
	static int on_status(http_parser *parser, const char *at, size_t length);
	static int on_header_field(http_parser *parser, const char *at, size_t length);
	static int on_header_value(http_parser *parser, const char *at, size_t length);
	static int on_headers_complete(http_parser *parser);
	static int on_body(http_parser *parser, const char *at, size_t length);
	static int on_message_complete(http_parser *parser);
	static int on_chunk_header(http_parser *parser);
	static int on_chunk_complete(http_parser *parser);
};