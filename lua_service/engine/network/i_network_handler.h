#pragma once

#include "network_def.h"
#include <memory>

enum ENetworkHandlerType
{
	ENetworkHandler_Connect,
	ENetworkHandler_Listen,
	ENetworkHandlerType_Max,
};

class INetworkHandler : public std::enable_shared_from_this<INetworkHandler>
{
public:
	INetworkHandler(ENetworkHandlerType handler_type) : m_handler_type(handler_type) {}
	virtual ~INetworkHandler() {}
	virtual void OnClose(int err_num) = 0;
	virtual void OnOpen(int err_num) = 0;
	ENetworkHandlerType HandlerType() { return m_handler_type; }
	NetId GetNetId() { return m_netid; }
	void SetNetId(NetId netid) { m_netid = netid; }

	/*
	template <typename T>
	std::shared_ptr<T> GetSharedPtr()
	{
		return std::dynamic_pointer_cast<T>(this->shared_from_this());
	}
	template <typename T>
	T * GetPtr()
	{
		return dynamic_cast<T>(this);
	}
	*/

protected:
	ENetworkHandlerType m_handler_type = ENetworkHandlerType_Max;
	NetId m_netid = 0;
};
class INetConnectHandler : public INetworkHandler
{
public:
	INetConnectHandler() : INetworkHandler(ENetworkHandler_Connect) {}
	virtual ~INetConnectHandler() {}
	virtual void OnRecvData(char *data, uint32_t len) = 0;
	std::shared_ptr<INetConnectHandler> GetSharedPtr()
	{
		return std::dynamic_pointer_cast<INetConnectHandler>(this->shared_from_this());
	}
	INetConnectHandler * GetPtr()
	{
		return this;
	}
};
class INetListenHandler : public INetworkHandler
{
public:
	INetListenHandler() : INetworkHandler(ENetworkHandler_Listen) {}
	virtual ~INetListenHandler() {}
	virtual std::shared_ptr<INetConnectHandler> GenConnectorHandler() = 0;
	std::shared_ptr<INetListenHandler> GetSharedPtr()
	{
		return std::dynamic_pointer_cast<INetListenHandler>(this->shared_from_this());
	}
	INetListenHandler * GetPtr()
	{
		return this;
	}
};

