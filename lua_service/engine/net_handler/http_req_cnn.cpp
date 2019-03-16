#include "http_req_cnn.h"
#include "iengine.h"
#include <regex>
#include <chrono>
#include <ctime>
#include <regex>

static const int PARSE_HTTP_FAIL = -100;
static const int PARSE_HTTP_SUCC = 0;

static const std::string Method_Name_Map[HttpReqCnn::Method_Count] = {
	"GET",
	"POST",
	"PUT",
	"DELETE"
};

HttpReqCnn::HttpReqCnn(std::weak_ptr<NetHandlerMap<INetConnectHandler>>  cnn_map)
{
	m_cnn_map = cnn_map;
	m_recv_buff = new NetBuffer(128, 64, mempool_malloc, mempool_free, mempool_realloc);
	m_rsp_body = new NetBuffer(128, 64, mempool_malloc, mempool_free, mempool_realloc);
	m_req_data_buff = new NetBuffer(128, 64, mempool_malloc, mempool_free, mempool_realloc);
}

HttpReqCnn::~HttpReqCnn()
{
	delete m_recv_buff; m_recv_buff = nullptr;
	delete m_rsp_body; m_rsp_body = nullptr;
	delete m_rsp_body; m_rsp_body = nullptr;
	mempool_free(m_parser); m_parser = nullptr;
	mempool_free(m_parser_setting); m_parser_setting = nullptr;
}

void HttpReqCnn::OnClose(int err_num)
{
	if (nullptr != m_process_event_fn)
	{
		m_process_event_fn(this, eActionType_Close, err_num);
	}
	if (0 != err_num)
	{
		log_error("HttpReqCnn::OnClose {}", err_num);
	}
	auto ap_cnn_map = m_cnn_map.lock();
	if (ap_cnn_map)
	{
		ap_cnn_map->Remove(m_netid);
	}
}

void HttpReqCnn::OnOpen(int err_num)
{
	// log_debug("HttpReqCnn::OnOpen {} {}", m_netid, err_num);

	if (nullptr != m_process_event_fn)
	{
		m_process_event_fn(this, eActionType_Open, err_num);
	}

	if (0 != err_num)
	{
	}
	else
	{
		auto sp_cnn_map = m_cnn_map.lock();
		if (sp_cnn_map)
		{
			sp_cnn_map->Add(this->GetSharedPtr());
		}

		m_parser = (http_parser *)mempool_malloc(sizeof(http_parser));
		m_parser->data = this;
		http_parser_init(m_parser, HTTP_RESPONSE);
		m_parser_setting = (http_parser_settings *)mempool_malloc(sizeof(http_parser_settings));
		http_parser_settings_init(m_parser_setting);
		m_parser_setting->on_message_begin = HttpReqCnn::on_message_begin;
		m_parser_setting->on_status = HttpReqCnn::on_status;
		m_parser_setting->on_header_field = HttpReqCnn::on_header_field;
		m_parser_setting->on_header_value = HttpReqCnn::on_header_value;
		m_parser_setting->on_headers_complete = HttpReqCnn::on_headers_complete;
		m_parser_setting->on_body = HttpReqCnn::on_body;
		m_parser_setting->on_message_complete = HttpReqCnn::on_message_complete;
		m_parser_setting->on_chunk_header = HttpReqCnn::on_chunk_header;
		m_parser_setting->on_chunk_complete = HttpReqCnn::on_chunk_complete;
		net_send(m_netid, m_req_data_buff->HeadPtr(), m_req_data_buff->Size());
	}
}


void HttpReqCnn::OnRecvData(char * data, uint32_t len)
{
	m_recv_buff->AppendBuff(data, len);
	std::string recv_str = std::string(m_recv_buff->HeadPtr(), m_recv_buff->Size());
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
	// log_debug("HttpReqCnn::OnRecvData {} {} \n{}", m_netid, len, recv_str);
}

bool HttpReqCnn::SetReqData(Method method, const std::string &url, const std::unordered_map<std::string, std::string> *heads_input, const std::string *content)
{
	if (method < 0 || method >= Method_Count)
		return false;

	std::string match_pattern_str = R"raw(((http[s]?://)?([\S]+?))(:([1-9][0-9]*))?(/[\S]+)?)raw";
	// log_debug("HttpReqCnn::SetReqData match_pattern {}", match_pattern_str);
	std::regex match_pattern(match_pattern_str, std::regex::icase);
	std::smatch match_ret;
	bool is_match = regex_match(url, match_ret, match_pattern);
	if (!is_match)
	{
		return false;
	}/*
	for (int i = 0; i < match_ret.size(); ++i)
	{
		std::ssub_match sub_match = match_ret[i];
		// log_debug(" sub_match {} {}", i, sub_match.str());
	}
	*/
	m_port = 80;
	std::string port = match_ret[5].str();
	if (port.size() > 0)
	{
		try { m_port = std::stoi(port); }
		catch (std::exception) 
		{
			return false;
		}
	}
	m_host = match_ret[3].str();
	if (m_host.size() <= 0)
	{
		return false;
	}
	m_method = match_ret[6].str();
	std::string full_host = fmt::format("{}:{}", m_host, m_port);
	std::unordered_map<std::string, std::string> heads;
	if (nullptr != heads_input)
	{
		heads.insert(heads_input->begin(), heads_input->end());
	}
	std::string req_line = fmt::format("{} {} HTTP/1.1\r\n", Method_Name_Map[method], m_method);
	m_req_data_buff->Append(req_line);
	heads.insert_or_assign("User-Agent", "utopia-http-client");
	heads.insert_or_assign("Accept", "*/*");
	heads.insert_or_assign("Host", full_host);
	heads.insert_or_assign("Content-Length", fmt::format("{}", nullptr != content ? content->size() : 0));
	{
		char time_str[256];
		std::time_t t = std::time(nullptr);
		std::strftime(time_str, sizeof(time_str), "%Y-%m-%d %H:%M:%S", std::localtime(&t));
		heads.insert_or_assign("Date", time_str);
	}
	const std::string head_line_format = "{}: {}\r\n";
	for (auto kv : heads)
	{
		std::string head_str = fmt::format(head_line_format, kv.first, kv.second);
		m_req_data_buff->Append(head_str);
	}
	m_req_data_buff->Append(std::string("\r\n"));
	if (nullptr != content)
	{
		m_req_data_buff->Append(*content);
	}
	// log_debug("req strs \n{}\n\n", std::string(m_req_data_buff->HeadPtr(), m_req_data_buff->Size()));
	return true;
}

void HttpReqCnn::ProcessRsp()
{
	if (nullptr != m_process_event_fn)
	{
		m_process_event_fn(this, eActionType_Parse, 0);
	}
	if (nullptr != m_process_rsp_fn)
	{
		m_process_rsp_fn(this, m_rsp_state, m_rsp_heads, 
			std::string(m_rsp_body->HeadPtr(), m_rsp_body->Size()), m_rsp_body->Size());
	}
	else
	{
		net_close(m_netid);
	}
}

int HttpReqCnn::on_message_begin(http_parser * parser)
{
	HttpReqCnn *self = (HttpReqCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	// log_debug("HttpReqCnn::on_message_begin {} ", self->m_netid);
	self->m_recv_buff->ResetHead();
	self->m_handling_head = EHandlingHead_None;
	self->m_req_head_kv.Reset();
	self->m_rsp_state = std::string();
	self->m_rsp_heads.clear();
	self->m_rsp_body->PopBuff(self->m_rsp_body->Size(), nullptr);
	self->m_rsp_body->ResetHead();
	return 0;
}

int HttpReqCnn::on_status(http_parser * parser, const char * at, size_t length)
{
	HttpReqCnn *self = (HttpReqCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	self->m_rsp_state.append(at, length);
	// log_debug("HttpReqCnn::on_status {} {} ", self->m_netid, self->m_rsp_state);
	return 0;
}

int HttpReqCnn::on_header_field(http_parser * parser, const char * at, size_t length)
{
	HttpReqCnn *self = (HttpReqCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	if (EHandlingHead_Key != self->m_handling_head)
	{
		self->CollectHead();
	}

	self->m_handling_head = EHandlingHead_Key;
	self->m_req_head_kv.key.append(at, length);
	// log_debug("HttpReqCnn::on_header_field {} {} {}", self->m_netid, self->m_req_head_kv.key, length);

	return 0;
}

int HttpReqCnn::on_header_value(http_parser * parser, const char * at, size_t length)
{
	HttpReqCnn *self = (HttpReqCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	std::string head_val(at, length); head_val.push_back(0);

	self->m_handling_head = EHandlingHead_Val;
	self->m_req_head_kv.val.append(at, length);

	// log_debug("HttpReqCnn::on_header_value {} {}", self->m_netid, self->m_req_head_kv.val);
	return 0;
}

int HttpReqCnn::on_headers_complete(http_parser * parser)
{
	HttpReqCnn *self = (HttpReqCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	// log_debug("HttpReqCnn::on_headers_complete {}, content_length {}", self->m_netid, self->m_parser->content_length);
	self->CollectHead();
	return 0;
}

int HttpReqCnn::on_body(http_parser * parser, const char * at, size_t length)
{
	HttpReqCnn *self = (HttpReqCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	self->m_rsp_body->AppendBuff(at, length);
	// log_debug("HttpReqCnn::on_body {} {} ", self->m_netid, std::string(self->m_rsp_body->HeadPtr(), self->m_rsp_body->Size()));
	return 0;
}

int HttpReqCnn::on_message_complete(http_parser * parser)
{
	HttpReqCnn *self = (HttpReqCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	self->m_rsp_body->AppendBuff("\0", 1);
	// log_debug("HttpReqCnn::on_message_complete {} body:\n{}", self->m_netid, self->m_rsp_body->HeadPtr());
	self->ProcessRsp();
	return 0;
}

int HttpReqCnn::on_chunk_header(http_parser * parser)
{
	HttpReqCnn *self = (HttpReqCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	// log_debug("HttpReqCnn::on_chunk_header {}", self->m_netid);
	return 0;
}

int HttpReqCnn::on_chunk_complete(http_parser * parser)
{
	HttpReqCnn *self = (HttpReqCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	// log_debug("HttpReqCnn::on_chunk_complete {}", self->m_netid);
	return 0;
}

void HttpReqCnn::CollectHead()
{
	if (m_req_head_kv.key.size() > 0)
	{
		m_rsp_heads.insert_or_assign(m_req_head_kv.key, m_req_head_kv.val);
	}
	m_handling_head = EHandlingHead_None;
	m_req_head_kv.Reset();
}
