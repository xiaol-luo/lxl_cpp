#include "net_proto_splitter.h"
#include "iengine.h"
#if WIN32
#include <WinSock2.h>
#else
#include <arpa/inet.h>
#include <unistd.h>
#endif

NetContentSplitter::NetContentSplitter(uint32_t package_max_size)
{
	m_buff = new NetBuffer(128, 64, mempool_malloc, mempool_free, mempool_realloc);
	m_package_max_size = package_max_size;
}

NetContentSplitter::~NetContentSplitter()
{
	delete m_buff; m_buff = nullptr;
}

bool NetContentSplitter::Append(char * data, uint32_t len)
{
	if (m_is_fail)
		return false;
	if (!m_buff->AppendBuff(data, len))
	{
		m_is_fail = true;
	}
	return m_is_fail;
}

bool NetContentSplitter::ParseNext()
{
	if (m_is_fail)
		return false;

	int buff_size = m_buff->Size();
	if (buff_size < LEN_BYTES)
		return false;
	char *p = m_buff->HeadPtr();
	uint32_t ctx_len = ntohl(*(uint32_t *)p);
	if (ctx_len >= m_package_max_size)
	{
		log_error("NetContentSplitter::ParseNext ctx_len: {}, limit is {}", ctx_len, m_package_max_size);
		m_is_fail = true;
		return false;
	}
	if (buff_size - LEN_BYTES < ctx_len)
		return false;
	char *help_buf = (char *)mempool_malloc(buff_size);
	if (nullptr == help_buf)
	{
		m_is_fail = true;
		return false;
	}
	m_buff->ResetHead(help_buf, buff_size);
	mempool_free(help_buf); help_buf = nullptr;
	m_ctx = m_buff->HeadPtr() + LEN_BYTES;
	m_ctx_len = ctx_len;
	return true;
}

void NetContentSplitter::PopUsingBuffer()
{
	if (nullptr != m_ctx)
	{
		m_buff->PopBuff(LEN_BYTES + m_ctx_len, nullptr);
		m_ctx = nullptr;
		m_ctx_len = 0;
	}
}

bool NetContentSplitter::IsFail()
{
	return m_is_fail;
}

uint32_t NetContentSplitter::CtxLen()
{
	return m_ctx_len;
}

char * NetContentSplitter::Ctx()
{
	return m_ctx;
}

NetPidContentSplitter::NetPidContentSplitter(uint32_t package_max_size) : NetContentSplitter(package_max_size)
{
}

NetPidContentSplitter::~NetPidContentSplitter()
{
}

bool NetPidContentSplitter::ParseNext()
{
	bool ret = false;
	if (NetContentSplitter::ParseNext() && !m_is_fail)
	{
		if (m_ctx_len < PID_BYTES)
		{
			m_is_fail = true;
			ret = false;
		}
		else
		{
			m_pid = ntohl(*(uint32_t *)m_ctx);
			m_ctx = m_ctx + PID_BYTES;
			m_ctx_len = m_ctx_len - PID_BYTES;
			ret = true;
		}
	}
	return ret;
}

void NetPidContentSplitter::PopUsingBuffer()
{
	if (nullptr != m_ctx)
	{
		NetContentSplitter::PopUsingBuffer();
		m_buff->PopBuff(PID_BYTES, nullptr);
		m_pid = 0;
	}
}

uint32_t NetPidContentSplitter::Pid()
{
	return m_pid;
}
