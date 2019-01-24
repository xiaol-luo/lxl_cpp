#include "http_rsp_cnn.h"
#include "http_rsp_cnn_mgr.h"
#include "iengine.h"

static const int PARSE_HTTP_FAIL = -100;
static const int PARSE_HTTP_SUCC = 0;

HttpRspCnn::HttpRspCnn(std::weak_ptr<HttpRspCnnMgr> mgr)
{
	m_mgr = mgr;
	m_buff = new NetBuffer(128, 64, mempool_malloc, mempool_free, mempool_realloc);
}

HttpRspCnn::~HttpRspCnn()
{
	delete m_buff; m_buff = nullptr;
	mempool_free(m_parser); m_parser = nullptr;
	mempool_free(m_parser_setting); m_parser_setting = nullptr;
}

void HttpRspCnn::OnClose(int err_num)
{
	if (0 != err_num)
	{
		log_error("HttpRspCnn::OnClose", err_num);
	}
	else
	{
		std::shared_ptr<HttpRspCnnMgr> sp_mgr = m_mgr.lock();
		if (sp_mgr)
		{
			sp_mgr->RemoveRspCnn(m_netid);
		}
	}
}

void HttpRspCnn::OnOpen(int err_num)
{
	if (0 != err_num)
	{
		log_error("HttpRspCnn::OnOpen", err_num);
	}
	else
	{
		std::shared_ptr<HttpRspCnnMgr> sp_mgr = m_mgr.lock();
		if (sp_mgr)
		{
			sp_mgr->AddRspCnn(this->GetSharedPtr<HttpRspCnn>());
			m_parser = (http_parser *)mempool_malloc(sizeof(http_parser));
			m_parser->data = this;
			http_parser_init(m_parser, HTTP_RESPONSE);
			m_parser_setting = (http_parser_settings *)mempool_malloc(sizeof(http_parser_settings));
			http_parser_settings_init(m_parser_setting);
			m_parser_setting->on_message_begin = HttpRspCnn::on_message_begin;
			m_parser_setting->on_url = HttpRspCnn::on_url;
			m_parser_setting->on_status = HttpRspCnn::on_status;
			m_parser_setting->on_header_field = HttpRspCnn::on_header_field;
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
	m_buff->AppendBuff(data, len);

}

int HttpRspCnn::on_message_begin(http_parser * parser)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	log_debug("HttpRspCnn::on_message_begin ", self->m_netid);
	return 0;
}

int HttpRspCnn::on_url(http_parser * parser, const char * at, size_t length)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	log_debug("HttpRspCnn::on_url ", self->m_netid);
	return 0;
}

int HttpRspCnn::on_status(http_parser * parser, const char * at, size_t length)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	log_debug("HttpRspCnn::on_status ", self->m_netid);
	return 0;
}

int HttpRspCnn::on_header_field(http_parser * parser, const char * at, size_t length)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	log_debug("HttpRspCnn::on_header_field ", self->m_netid);
	return 0;
}

int HttpRspCnn::on_headers_complete(http_parser * parser)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	log_debug("HttpRspCnn::on_headers_complete ", self->m_netid);
	return 0;
}

int HttpRspCnn::on_body(http_parser * parser, const char * at, size_t length)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	log_debug("HttpRspCnn::on_body ", self->m_netid);
	return 0;
}

int HttpRspCnn::on_message_complete(http_parser * parser)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	log_debug("HttpRspCnn::on_message_complete ", self->m_netid);
	return 0;
}

int HttpRspCnn::on_chunk_header(http_parser * parser)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	log_debug("HttpRspCnn::on_chunk_header ", self->m_netid);
	return 0;
}

int HttpRspCnn::on_chunk_complete(http_parser * parser)
{
	HttpRspCnn *self = (HttpRspCnn *)parser->data;
	if (nullptr == self)
		return PARSE_HTTP_FAIL;

	log_debug("HttpRspCnn::on_chunk_complete ", self->m_netid);

	net_close(self->m_netid);
	return 0;
}
