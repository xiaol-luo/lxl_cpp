#pragma once

#include "network/i_network_handler.h"
#include "net_handler_map.h"
#include <functional>

class CommonConnecter;

struct CommonCnnCallback
{
	std::function<void(CommonConnecter* /*self*/, int /*err_num*/)> on_open = nullptr;
	std::function<void(CommonConnecter* /*self*/, int /*err_num*/)> on_close = nullptr;
	std::function<void(CommonConnecter* /*self*/, char * /*data*/, uint32_t /*data_len*/)> on_recv = nullptr;
};

class CommonConnecter : public INetConnectHandler
{
public:
	CommonConnecter();
	CommonConnecter(std::weak_ptr<NetHandlerMap<INetConnectHandler>> cnn_map);
	virtual ~CommonConnecter();
	void SetCb(CommonCnnCallback & cb);
	virtual void OnClose(int err_num) override;
	virtual void OnOpen(int err_num) override;
	virtual void OnRecvData(char *data, uint32_t len) override;

protected:
	std::weak_ptr<NetHandlerMap<INetConnectHandler>> m_cnn_map;
	CommonCnnCallback m_cb;
};

