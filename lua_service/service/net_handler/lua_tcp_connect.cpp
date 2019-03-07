#include "lua_tcp_connect.h"
#include "iengine.h"
#if WIN32
#include <WinSock2.h>
#else
#include <arpa/inet.h>
#include <unistd.h>
#endif

LuaTcpConnect::LuaTcpConnect()
{
	m_pid_ctx_splitter = new NetPidContentSplitter();
	m_buff = new NetBuffer(128, 64, mempool_malloc, mempool_free, mempool_realloc);
}

LuaTcpConnect::~LuaTcpConnect()
{
	delete m_pid_ctx_splitter; m_pid_ctx_splitter = nullptr;
	delete m_buff; m_buff = nullptr;
}

void LuaTcpConnect::OnClose(int err_num)
{
	m_lua_logic[LUA_CNN_CB_ONCLOSE](m_lua_logic, err_num);
}

void LuaTcpConnect::OnOpen(int err_num)
{
	m_lua_logic[LUA_CNN_CB_ONOPEN](m_lua_logic, err_num);
}

void LuaTcpConnect::OnRecvData(char * data, uint32_t len)
{
	if (!m_pid_ctx_splitter->IsFail())
	{
		m_pid_ctx_splitter->Append(data, len);
		while (!m_pid_ctx_splitter->IsFail() && m_pid_ctx_splitter->ParseNext())
		{
			uint32_t pid = m_pid_ctx_splitter->Pid();
			char *ctx = m_pid_ctx_splitter->Ctx();
			uint32_t ctx_len = m_pid_ctx_splitter->CtxLen();
			if (ctx_len > 0)
			{

				std::string bin(ctx, ctx_len);
				m_lua_logic[LUA_CNN_CB_ONRECV](m_lua_logic, pid, bin);
			}
			else
			{
				m_lua_logic[LUA_CNN_CB_ONRECV](m_lua_logic, pid);
			}
			m_pid_ctx_splitter->PopUsingBuffer();
		}
		if (m_pid_ctx_splitter->IsFail())
		{
			// todo close
			net_close(m_netid);
		}
	}
}

bool LuaTcpConnect::Init(sol::table lua_logic)
{
	if (!lua_logic.valid())
		return false;

	m_lua_logic = lua_logic;
	{
		sol::object fn = m_lua_logic.get<sol::object>(LUA_CNN_CB_ONCLOSE);
		assert(fn.is<sol::function>());
	}
	{
		sol::object fn = m_lua_logic.get<sol::object>(LUA_CNN_CB_ONOPEN);
		assert(fn.is<sol::function>());
	}
	{
		sol::object fn = m_lua_logic.get<sol::object>(LUA_CNN_CB_ONRECV);
		assert(fn.is<sol::function>());
	}
	return true;
}

bool LuaTcpConnect::Send(uint32_t pid)
{
	if (m_netid <= 0)
		return false;

	uint32_t buff_len = sizeof(uint32_t) + sizeof(pid);
	char *buff = (char *)mempool_malloc(buff_len);
	*(uint32_t *)buff = htonl(sizeof(pid));
	*(uint32_t *)(buff + sizeof(pid)) = htonl(pid);
	net_send(m_netid, buff, buff_len);
	mempool_free(buff); buff = nullptr;
	return true;
}

bool LuaTcpConnect::Send(uint32_t pid, const std::string & data)
{
	if (m_netid <= 0)
		return false;

	uint32_t ctx_len = sizeof(pid) + data.size();
	uint32_t buff_len = sizeof(uint32_t) + ctx_len;
	char *buff = (char *)mempool_malloc(buff_len);
	char *p = buff;
	*(uint32_t *)p = htonl(ctx_len); p += sizeof(uint32_t);
	*(uint32_t *)p = htonl(pid); p += sizeof(uint32_t);
	memcpy(p, data.data(), data.size());
	net_send(m_netid, buff, buff_len);
	mempool_free(buff); buff = nullptr;
	return true;
}
