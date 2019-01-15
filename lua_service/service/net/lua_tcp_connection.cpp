#include "lua_tcp_connection.h"
#include "iengine.h"

LuaTcpConnection::LuaTcpConnection()
{
	m_pid_ctx_splitter = new NetPidContentSplitter();
	m_buff = new NetBuffer(128, 64, mempool_malloc, mempool_free, mempool_realloc);
}

LuaTcpConnection::~LuaTcpConnection()
{
	delete m_pid_ctx_splitter; m_pid_ctx_splitter = nullptr;
	delete m_buff; m_buff = nullptr;
}

void LuaTcpConnection::OnClose(int err_num)
{
	m_lua_logic[LUA_CNN_CB_ONCLOSE](err_num);
}

void LuaTcpConnection::OnOpen(int err_num)
{
	m_lua_logic[LUA_CNN_CB_ONOPEN](err_num);
}

void LuaTcpConnection::OnRecvData(char * data, uint32_t len)
{
	if (!m_pid_ctx_splitter->IsFail())
	{
		m_pid_ctx_splitter->Append(data, len);
		while (!m_pid_ctx_splitter->IsFail() && m_pid_ctx_splitter->ParseNext())
		{
			uint32_t pid = m_pid_ctx_splitter->Pid();
			char *ctx = m_pid_ctx_splitter->Ctx();
			uint32_t ctx_len = m_pid_ctx_splitter->CtxLen();
			std::string bin(ctx, ctx_len);
			m_lua_logic[LUA_CNN_CB_ONRECV](pid, bin);
		}
		if (m_pid_ctx_splitter->IsFail())
		{
			// todo close
			net_close(m_netid);
		}
	}
}

bool LuaTcpConnection::Init(sol::table lua_logic)
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

bool LuaTcpConnection::Send(uint32_t pid)
{
	return false;
}

bool LuaTcpConnection::Send(uint32_t pid, std::string & data)
{
	return false;
}
