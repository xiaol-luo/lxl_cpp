#pragma once

#include <string>
#include <functional>
#include <stdint.h>
#include <sol/sol.hpp>

class IEtcdClient
{
public:
	virtual ~IEtcdClient() {}
	using CallbackFn = std::function<void(uint64_t/*id*/, const std::string &/*json_ret*/)>;
	virtual uint64_t Set(const std::string &key, const std::string &val, uint32_t ttl, bool is_dir, CallbackFn cb_fn) = 0;
	virtual uint64_t RefreshTtl(const std::string &key, uint32_t ttl, bool is_dir, CallbackFn cb_fn) = 0;
	virtual uint64_t Get(const std::string &key, bool recursive, CallbackFn cb_fn) = 0;
	virtual uint64_t Delete(const std::string &key, bool recursive, CallbackFn cb_fn) = 0;
	virtual uint64_t Watch(const std::string &key, bool recursive, uint64_t waitIndex ,CallbackFn cb_fn) = 0;
	virtual uint64_t CmpSwap(const std::string &key, uint64_t prev_index, const std::string &prev_val, const std::string &val, CallbackFn cb_fn) = 0;
	virtual uint64_t CmpDelete(const std::string &key, uint64_t prev_index, const std::string &prev_val, bool recursive, CallbackFn cb_fn) = 0;
};