#include "etcd_client.h"

EtcdClient::EtcdClient(lua_State *L, const std::string & host, const std::string & user, const std::string & pwd)
{
	sol::state_view sv(L);
	sol::function instance_fn = sv["EtcdClientCxx"]["instance_one"];
	m_lua_etcd_client = instance_fn(host, user, pwd);
	assert(m_lua_etcd_client.valid());
}

EtcdClient::~EtcdClient()
{
	m_lua_etcd_client = sol::nil;
}

uint64_t EtcdClient::Set(const std::string & key, const std::string & val, uint32_t ttl, bool is_dir, CallbackFn cb_fn)
{
	return uint64_t();
}

uint64_t EtcdClient::RefreshTtl(const std::string & key, uint32_t ttl, bool is_dir, CallbackFn cb_fn)
{
	return uint64_t();
}

uint64_t EtcdClient::Get(const std::string & key, bool recursive, CallbackFn cb_fn)
{
	return uint64_t();
}

uint64_t EtcdClient::Delete(const std::string & key, bool recursive, CallbackFn cb_fn)
{
	return uint64_t();
}

uint64_t EtcdClient::Watch(const std::string & key, bool recursive, uint64_t waitIndex, CallbackFn cb_fn)
{
	return uint64_t();
}

uint64_t EtcdClient::CmpSwap(const std::string & key, uint64_t prev_index, const std::string & prev_val, const std::string & val, CallbackFn cb_fn)
{
	return uint64_t();
}

uint64_t EtcdClient::CmpDelete(const std::string & key, uint64_t prev_index, const std::string & prev_val, bool recursive, CallbackFn cb_fn)
{
	return uint64_t();
}
