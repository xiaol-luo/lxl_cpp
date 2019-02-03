#include "common_cnn_handler.h"

CommonConnecter::CommonConnecter()
{

}

CommonConnecter::CommonConnecter(std::weak_ptr<NetHandlerMap<INetConnectHandler>> cnn_map)
{
	m_cnn_map = cnn_map;
}

CommonConnecter::~CommonConnecter()
{

}

void CommonConnecter::SetCb(CommonCnnCallback & cb)
{
	m_cb = cb;
}

void CommonConnecter::OnClose(int err_num)
{
	auto sp_cnn_map = m_cnn_map.lock();
	if (nullptr != sp_cnn_map)
	{
		sp_cnn_map->Remove(m_netid);
	}
	if (nullptr != m_cb.on_close)
	{
		m_cb.on_close(this, err_num);
	}
}

void CommonConnecter::OnOpen(int err_num)
{
	if (0 == err_num)
	{
		auto sp_cnn_map = m_cnn_map.lock();
		if (nullptr != sp_cnn_map)
		{
			sp_cnn_map->Add(this->GetSharedPtr());
		}
	}
	if (nullptr != m_cb.on_open)
	{
		m_cb.on_open(this, err_num);
	}
}

void CommonConnecter::OnRecvData(char * data, uint32_t len)
{
	if (nullptr != m_cb.on_recv)
	{
		m_cb.on_recv(this, data, len);
	}
}
