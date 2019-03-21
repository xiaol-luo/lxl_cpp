#pragma once

#include "i_etcd_client.h"
#include <sol/sol.hpp>

class EtcdClient : public IEtcdClient
{
public:
	EtcdClient(lua_State *L, const std::string &host, const std::string &user, const std::string &pwd);
	virtual ~EtcdClient();
	virtual uint64_t Set(const std::string &key, const std::string &val, uint32_t ttl, bool is_dir, CallbackFn cb_fn) override;
	virtual uint64_t RefreshTtl(const std::string &key, uint32_t ttl, bool is_dir, CallbackFn cb_fn) override;
	virtual uint64_t Get(const std::string &key, bool recursive, CallbackFn cb_fn) override;
	virtual uint64_t Delete(const std::string &key, bool recursive, CallbackFn cb_fn)  override;
	virtual uint64_t Watch(const std::string &key, bool recursive, uint64_t waitIndex, CallbackFn cb_fn)  override;
	virtual uint64_t CmpSwap(const std::string &key, uint64_t prev_index, const std::string &prev_val, const std::string &val, CallbackFn cb_fn)  override;
	virtual uint64_t CmpDelete(const std::string &key, uint64_t prev_index, const std::string &prev_val, bool recursive, CallbackFn cb_fn)  override;

protected:
	sol::table m_lua_etcd_client;
	lua_State *m_lua_state = nullptr;
	sol::optional<sol::protected_function> MakeOpCbFn(IEtcdClient::CallbackFn fn);
};