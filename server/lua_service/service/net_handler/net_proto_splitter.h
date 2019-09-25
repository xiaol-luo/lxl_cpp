#pragma once

#include "buffer/net_buffer.h"

#define NET_CTX_DEFAULT_MAX_SIZE 102400

class NetContentSplitter
{
public:
	const uint32_t LEN_BYTES = sizeof(uint32_t);
	
	NetContentSplitter(uint32_t package_max_size = NET_CTX_DEFAULT_MAX_SIZE);
	virtual ~NetContentSplitter();

	bool Append(char *data, uint32_t len);
	virtual bool ParseNext();
	virtual void PopUsingBuffer();
	bool IsFail();
	uint32_t CtxLen();
	char * Ctx();

protected:
	NetBuffer *m_buff = nullptr;
	char *m_ctx = nullptr;
	uint32_t m_ctx_len = 0;
	bool m_is_fail = false;
	uint32_t m_package_max_size = 0;
};

class NetPidContentSplitter : public NetContentSplitter
{
public:
	const uint32_t PID_BYTES = sizeof(uint32_t);
public:
	NetPidContentSplitter(uint32_t package_max_size = NET_CTX_DEFAULT_MAX_SIZE);
	virtual ~NetPidContentSplitter();
	virtual bool ParseNext() override;
	virtual void PopUsingBuffer() override;
	uint32_t Pid();

protected:
	uint32_t m_pid = 0;
};