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
	this->ReleaseAll();
}

void CommonConnecter::SetCb(CommonCnnCallback & cb)
{
	m_cb = cb;
}

void CommonConnecter::OnClose(int error_num)
{
	auto sp_cnn_map = m_cnn_map.lock();
	if (nullptr != sp_cnn_map)
	{
		sp_cnn_map->Remove(m_netid);
	}
	if (nullptr != m_cb.on_close)
	{
		m_cb.on_close(this, error_num);
	}
	this->ReleaseAll();
}

void CommonConnecter::OnOpen(int error_num)
{
	if (0 == error_num)
	{
		auto sp_cnn_map = m_cnn_map.lock();
		if (nullptr != sp_cnn_map)
		{
			sp_cnn_map->Add(this->GetSharedPtr());
		}
	}
	if (nullptr != m_cb.on_open)
	{
		m_cb.on_open(this, error_num);
	}
}

void CommonConnecter::OnRecvData(char * data, uint32_t len)
{
	if (nullptr != m_cb.on_recv)
	{
		m_cb.on_recv(this, data, len);
	}
}

void CommonConnecter::ReleaseAll()
{
	m_cb.reset();
}
