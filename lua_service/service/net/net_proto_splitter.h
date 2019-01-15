#pragma once

#include "buffer/net_buffer.h"

class NetContentSplitter
{
public:
	const uint32_t LEN_BYTES = sizeof(uint32_t);
	
	NetContentSplitter();
	virtual ~NetContentSplitter();

	bool Append(char *data, uint32_t len);
	virtual bool ParseNext();
	bool IsFail();
	uint32_t CtxLen();
	char * Ctx();

protected:
	NetBuffer *m_buff = nullptr;
	char *m_ctx = nullptr;
	uint32_t m_ctx_len = 0;
	bool m_is_fail = false;
};

class NetPidContentSplitter : public NetContentSplitter
{
public:
	const uint32_t PID_BYTES = sizeof(uint32_t);
public:
	NetPidContentSplitter();
	virtual ~NetPidContentSplitter();
	virtual bool ParseNext() override;
	uint32_t Pid();

protected:
	uint32_t m_pid = 0;
};