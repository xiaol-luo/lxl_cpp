#pragma once

#include "network/i_network_handler.h"
#include "net_handler_map.h"
#include <functional>

class CommonListener;

struct CommonListenCallback
{
	std::function<void(CommonListener* /*self*/, std::shared_ptr<INetConnectHandler> /*cnn*/)> on_add_cnn = nullptr;
	std::function<void(CommonListener* /*self*/, NetId /*netid*/)> on_remove_cnn = nullptr;
	std::function<void(CommonListener* /*self*/, int /*err_num*/)> on_open = nullptr;
	std::function<void(CommonListener* /*self*/, int /*err_num*/)> on_close = nullptr;
	std::function<std::shared_ptr<INetConnectHandler>(CommonListener* /*self*/)> do_gen_cnn_handler = nullptr;
};

class CommonListener : public INetListenHandler
{
public:
	CommonListener();
	virtual ~CommonListener();

	void SetCb(CommonListenCallback &cb);
	NetId Listen(int port);
	int64_t ListenAsync(int port);
	bool AddCnn(std::shared_ptr<INetConnectHandler> cnn);
	void RemoveCnn(NetId netid);
	virtual void OnClose(int err_num) override;
	virtual void OnOpen(int err_num) override;
	virtual std::shared_ptr<INetConnectHandler> GenConnectorHandler() override;
	std::weak_ptr<NetHandlerMap<INetConnectHandler>> GetCnnMap() { return m_cnn_map; }

protected:
	std::shared_ptr<NetHandlerMap<INetConnectHandler>> m_cnn_map;
	CommonListenCallback m_cb;
	int m_port = -1;
};