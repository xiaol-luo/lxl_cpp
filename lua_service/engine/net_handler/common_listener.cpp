#include "common_listener.h"
#include "iengine.h"
#include <sol/sol.hpp>

CommonListener::CommonListener()
{
	m_cnn_map = std::make_shared<NetHandlerMap<INetConnectHandler>>();
}

CommonListener::~CommonListener()
{
	m_cnn_map->Clear();
	m_cnn_map = nullptr;
}

void CommonListener::SetCb(CommonListenCallback & cb)
{
	m_cb = cb;
}

NetId CommonListener::Listen(int port)
{
	if (m_port >= 0)
		return INVALID_NET_ID;

	return net_listen("0.0.0.0", port, this->GetSharedPtr());
}

int64_t CommonListener::ListenAsync(int port)
{
	if (m_port >= 0)
		return 0;

	return net_listen_async("0.0.0.0", port, this->GetSharedPtr());
}

bool CommonListener::AddCnn(std::shared_ptr<INetConnectHandler> cnn)
{
	return m_cnn_map->Add(cnn);
	if (nullptr != m_cb.on_add_cnn)
	{
		m_cb.on_add_cnn(this, cnn);
	}
}

void CommonListener::RemoveCnn(NetId netid)
{
	m_cnn_map->Remove(netid);
	if (nullptr != m_cb.on_remove_cnn)
	{
		m_cb.on_remove_cnn(this, netid);
	}
}

void CommonListener::OnClose(int err_num)
{
	if (0 != err_num)
	{
		m_port = 0;
	}
	if (nullptr != m_cb.on_close)
	{
		m_cb.on_close(this, err_num);
	}
}

void CommonListener::OnOpen(int err_num)
{
	if (0 != err_num)
	{
		m_port = 0;
	}
	if (nullptr != m_cb.on_open)
	{
		m_cb.on_open(this, err_num);
	}
}

std::shared_ptr<INetConnectHandler> CommonListener::GenConnectorHandler()
{
	std::shared_ptr<INetConnectHandler> ret = nullptr;
	try
	{
		ret = m_cb.do_gen_cnn_handler(this);
	}
	catch (sol::error e)
	{
		ret = nullptr;
	}
	return ret;
}
