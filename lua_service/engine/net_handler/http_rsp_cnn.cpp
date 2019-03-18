#include "http_rsp_cnn.h"
#include "iengine.h"
#include <algorithm>

static const int PARSE_HTTP_FAIL = -100;
static const int PARSE_HTTP_SUCC = 0;

HttpRspCnn::HttpRspCnn(std::weak_ptr<NetHandlerMap<INetConnectHandler>>  cnn_map)
{
	m_cnn_map = cnn_map;
	m_recv_buff = new NetBuffer(128, 64, mempool_malloc, mempool_free, mempool_realloc);
	m_req_body = new NetBuffer(128, 64, mempool_malloc, mempool_free, mempool_realloc);
}

HttpRspCnn::~HttpRspCnn()
{
	delete m_recv_buff; m_recv_buff = nullptr;
	delete m_req_body; m_req_body = nullptr;
	mempool_free(m_parser); m_parser = nullptr;
	mempool_free(m_parser_setting); m_parser_setting = nullptr;
}

void HttpRspCnn::OnClose(int err_num)
{
	if (nullptr != m_process_event_fn)
	{
		m_process_event_fn(this, eActionType_Close, err_num);
	}
	if (0 != err_num)
	{
		log_error("HttpRspCnn::OnClose {}", err_num);
	}
	auto ap_cnn_map = m_cnn_map.lock();
	if (ap_cnn_map)
	{
		ap_cnn_map->Remove(m_netid);
	}
}

void HttpRspCnn::OnOpen(int err_num)
{
	if (nullptr != m_process_event_fn)
	{
		m_process_event_fn(this, eActionType_Open, err_num);
	}
	// log_debug("HttpRspCnn::OnOpen {} {}", m_netid, err_num);
	if (0 != err_num)
	{
	}
	else
	{
		auto sp_cnn_map = m_cnn_map.lock();
		if (sp_cnn_map)
		{
			sp_cnn_map->Add(this->GetSharedPtr());
			m_parser = (http_parser *)mempool_malloc(sizeof(http_parser));
			m_parser->data = this;
			http_parser_init(m_parser, HTTP_REQUEST);
			m_parser_setting = (http_parser_settings *)mempool_malloc(sizeof(http_parser_settings));
			http_parser_settings_init(m_parser_setting);
			m_parser_setting->on_message_begin = HttpRspCnn::on_message_begin;
			m_parser_setting->on_url = HttpRspCnn::on_url;
			m_parser_setting->on_header_field = HttpRspCnn::on_header_field;
			m_parser_setting->on_header_value = HttpRspCnn::on_header_value;
			m_parser_setting->on_headers_complete = HttpRspCnn::on_headers_complete;
			m_parser_setting->on_body = HttpRspCnn::on_body;
			m_parser_setting->on_message_complete = HttpRspCnn::on_message_complete;
			m_parser_setting->on_chunk_header = HttpRspCnn::on_chunk_header;
			m_parser_setting->on_chunk_complete = HttpRspCnn::on_chunk_complete;
		}
		else
		{
			net_close(m_netid);
		}
	}
}

void HttpRspCnn::OnRecvData(char * data, uint32_t len)
{
	m_recv_buff->AppendBuff(data, len);
	// log_debug("HttpRspCnn::OnRecvData \n{}", std::string(m_recv_buff->HeadPtr(), m_recv_buff->Size()));
	int parsed = http_parser_execute(m_parser, m_parser_setting, m_recv_buff->HeadPtr(), m_recv_buff->Size());
	if (parsed > 0)
	{
		m_recv_buff->PopBuff(parsed, nullptr);
	}
	if (m_parser->http_errno)
	{
		if (nullptr != m_process_event_fn)
		{
			m_process_event_fn(this, eActionType_Parse, m_parser->http_errno);
		}
		net_close(m_netid);
	}
	// log_debug("HttpRspCnn::OnRecvData {} {} used: {}/{}", m_netid, len, m_recv_buff->Head(), m_recv_buff->Pos());
}

void HttpRspCnn::ProcessReq()
{
	if (nullptr != m_process_event_fn)
	{
		m_process_event_fn(this, eActionType_Parse, 0);
	}

	bool is_processed = false;

	if (nullptr != m_process_req_fn)
	{
		is_processed = m_process_req_fn(this, m_parser->method, m_req_url, m_req_heads,
			std::string(m_req_body->HeadPtr(), m_req_body->Size()), m_req_body->Size());
	}
	if (!is_processed)
	{
		NetBuffer *send_buff = new NetBuffer(128, 64, mempool_malloc, mempool_free, mempool_realloc);
		std::string state_line = fmt::format("HTTP/1.1 {} {}\r\n", 404, "NotProcessLogic");
		send_buff->Append(state_line);
		const std::string head_line_format = "{}:{}\r\n";

		char time_str[256];
		{
			std::time_t t = std::time(nullptr);
			std::strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", std::localtime(&t));
		}
		std::unordered_map<std::string, std::string> heads = {
			{"Date", time_str},
			// {"Content-Type", "text/html;charset=UTF-8"},
			{"Content-Length", fmt::format("{}", 0)},
		};
		for (auto kv : heads)
		{
			std::string head_str = fmt::format(head_line_format, kv.first, kv.second);
			send_buff->Append(head_str);
		}
		send_buff->Append(std::string("\r\n"));
		net_send(m_netid, send_buff->HeadPtr(), send_buff->Size());
		net_close(m_netid);
		delete send_buff;
	}
}

int HttpRspCnn::on_message_begin(http_parser * parser)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	// log_debug("HttpRspCnn::on_message_begin {} ", self->m_netid);
	self->m_recv_buff->ResetHead();
	self->m_handling_head = EHandlingHead_None;
	self->m_req_head_kv.Reset();
	self->m_req_url = std::string();
	self->m_req_heads.clear();
	self->m_req_body->PopBuff(self->m_req_body->Size(), nullptr);
	self->m_req_body->ResetHead();
	return 0;
}

int HttpRspCnn::on_url(http_parser * parser, const char * at, size_t length)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	self->m_req_url.append(at, length);
	// log_debug("HttpRspCnn::on_url {} {} ", self->m_netid, self->m_req_url);
	return 0;
}

int HttpRspCnn::on_header_field(http_parser * parser, const char * at, size_t length)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	if (EHandlingHead_Key != self->m_handling_head)
	{
		self->CollectHead();
	}
	
	self->m_handling_head = EHandlingHead_Key;
	self->m_req_head_kv.key.append(at, length);
	// log_debug("HttpRspCnn::on_header_field {} {} {}", self->m_netid, self->m_req_head_kv.key, length);

	return 0;
}

int HttpRspCnn::on_header_value(http_parser * parser, const char * at, size_t length)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	std::string head_val(at, length); head_val.push_back(0);

	self->m_handling_head = EHandlingHead_Val;
	self->m_req_head_kv.val.append(at, length);

	// log_debug("HttpRspCnn::on_header_value {} {}", self->m_netid, self->m_req_head_kv.val);
	return 0;
}

int HttpRspCnn::on_headers_complete(http_parser * parser)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	// log_debug("HttpRspCnn::on_headers_complete {}, content_length {}", self->m_netid, self->m_parser->content_length);
	self->CollectHead();
	return 0;
}

int HttpRspCnn::on_body(http_parser * parser, const char * at, size_t length)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	self->m_req_body->AppendBuff(at, length);
	// log_debug("HttpRspCnn::on_body {} {} ", self->m_netid, std::string(self->m_req_body->HeadPtr(), self->m_req_body->Size()));
	return 0;
}

int HttpRspCnn::on_message_complete(http_parser * parser)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	// self->m_req_body->AppendBuff("\0", 1);
	// log_debug("HttpRspCnn::on_message_complete {} body:\n{}", self->m_netid, std::string(self->m_req_body->HeadPtr(), self->m_req_body->Size()));

	self->ProcessReq();

	return 0;
}

int HttpRspCnn::on_chunk_header(http_parser * parser)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	// log_debug("HttpRspCnn::on_chunk_header {}", self->m_netid);
	return 0;
}

int HttpRspCnn::on_chunk_complete(http_parser * parser)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	// log_debug("HttpRspCnn::on_chunk_complete {}", self->m_netid);
	return 0;
}

void HttpRspCnn::CollectHead()
{
	if (m_req_head_kv.key.size() > 0)
	{
		m_req_heads.insert_or_assign(m_req_head_kv.key, m_req_head_kv.val);
	}
	m_handling_head = EHandlingHead_None;
	m_req_head_kv.Reset();
}
