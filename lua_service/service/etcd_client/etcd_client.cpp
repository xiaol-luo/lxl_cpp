#include "etcd_client.h"
#include "iengine.h"

EtcdClient::EtcdClient(lua_State *L, const std::string & host, const std::string & user, const std::string & pwd)
{
	m_lua_state = L;
	sol::state_view sv(m_lua_state);
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
	sol::protected_function fn = m_lua_etcd_client["set"];
	sol::optional<sol::protected_function> lua_cb_fn = this->MakeOpCbFn(cb_fn);
	sol::protected_function_result pfr = fn(m_lua_etcd_client, key, val, ttl, is_dir, lua_cb_fn.value());
	uint64_t op_id = 0;
	if (pfr.valid())
	{
		op_id = pfr.get<uint64_t>(0);
	}
	else
	{
		sol::error err = pfr;
		sol::call_status status = pfr.status();
		log_error("EtcdClient::Set Error, status:{}, what:{}", (int)status, err.what());
	}
	return op_id;
}

uint64_t EtcdClient::RefreshTtl(const std::string & key, uint32_t ttl, bool is_dir, CallbackFn cb_fn)
{
	sol::protected_function fn = m_lua_etcd_client["refresh_ttl"];
	sol::optional<sol::protected_function> lua_cb_fn = this->MakeOpCbFn(cb_fn);
	sol::protected_function_result pfr = fn(key, ttl, is_dir, lua_cb_fn.value());
	uint64_t op_id = 0;
	if (pfr.valid())
	{
		op_id = pfr.get<uint64_t>(0);
	}
	else
	{
		sol::error err = pfr;
		sol::call_status status = pfr.status();
		log_error("EtcdClient::RefreshTtl Error, status:{}, what:{}", (int)status, err.what());
	}
	return op_id;
}

uint64_t EtcdClient::Get(const std::string & key, bool recursive, CallbackFn cb_fn)
{
	sol::protected_function fn = m_lua_etcd_client["get"];
	sol::optional<sol::protected_function> lua_cb_fn = this->MakeOpCbFn(cb_fn);
	sol::protected_function_result pfr = fn(key, recursive, lua_cb_fn.value());
	uint64_t op_id = 0;
	if (pfr.valid())
	{
		op_id = pfr.get<uint64_t>(0);
	}
	else
	{
		sol::error err = pfr;
		sol::call_status status = pfr.status();
		log_error("EtcdClient::Get Error, status:{}, what:{}", (int)status, err.what());
	}
	return op_id;
}

uint64_t EtcdClient::Delete(const std::string & key, bool recursive, CallbackFn cb_fn)
{
	sol::protected_function fn = m_lua_etcd_client["delete"];
	sol::optional<sol::protected_function> lua_cb_fn = this->MakeOpCbFn(cb_fn);
	sol::protected_function_result pfr = fn(key, recursive, lua_cb_fn.value());
	uint64_t op_id = 0;
	if (pfr.valid())
	{
		op_id = pfr.get<uint64_t>(0);
	}
	else
	{
		sol::error err = pfr;
		sol::call_status status = pfr.status();
		log_error("EtcdClient::Delete Error, status:{}, what:{}", (int)status, err.what());
	}
	return op_id;
}

uint64_t EtcdClient::Watch(const std::string & key, bool recursive, uint64_t waitIndex, CallbackFn cb_fn)
{
	sol::protected_function fn = m_lua_etcd_client["watch"];
	sol::optional<sol::protected_function> lua_cb_fn = this->MakeOpCbFn(cb_fn);
	sol::protected_function_result pfr = fn(key, recursive, waitIndex, lua_cb_fn.value());
	uint64_t op_id = 0;
	if (pfr.valid())
	{
		op_id = pfr.get<uint64_t>(0);
	}
	else
	{
		sol::error err = pfr;
		sol::call_status status = pfr.status();
		log_error("EtcdClient::Watch Error, status:{}, what:{}", (int)status, err.what());
	}
	return op_id;
}

uint64_t EtcdClient::CmpSwap(const std::string & key, uint64_t prev_index, const std::string & prev_val, const std::string & val, CallbackFn cb_fn)
{
	sol::protected_function fn = m_lua_etcd_client["cmp_swap"];
	sol::optional<sol::protected_function> lua_cb_fn = this->MakeOpCbFn(cb_fn);
	sol::protected_function_result pfr = fn(key, prev_index, prev_val, val, lua_cb_fn.value());
	uint64_t op_id = 0;
	if (pfr.valid())
	{
		op_id = pfr.get<uint64_t>(0);
	}
	else
	{
		sol::error err = pfr;
		sol::call_status status = pfr.status();
		log_error("EtcdClient::CmpSwap Error, status:{}, what:{}", (int)status, err.what());
	}
	return op_id;
}

uint64_t EtcdClient::CmpDelete(const std::string & key, uint64_t prev_index, const std::string & prev_val, bool recursive, CallbackFn cb_fn)
{
	sol::protected_function fn = m_lua_etcd_client["cmp_delete"];
	sol::optional<sol::protected_function> lua_cb_fn = this->MakeOpCbFn(cb_fn);
	sol::protected_function_result pfr = fn(key, prev_index, prev_val, recursive, lua_cb_fn.value());
	uint64_t op_id = 0;
	if (pfr.valid())
	{
		op_id = pfr.get<uint64_t>(0);
	}
	else
	{
		sol::error err = pfr;
		sol::call_status status = pfr.status();
		log_error("EtcdClient::CmpDelete Error, status:{}, what:{}", (int)status, err.what());
	}
	return op_id;
}

sol::optional<sol::protected_function> EtcdClient::MakeOpCbFn(IEtcdClient::CallbackFn fn)
{
	if (nullptr == fn)
		return sol::nil;

	sol::state_view sv(m_lua_state);
	sol::function help_fn = sv["EtcdClientCxx"]["make_op_cb_fn"];
	sol::optional<sol::protected_function> ret = help_fn(fn);
	return ret;
}
