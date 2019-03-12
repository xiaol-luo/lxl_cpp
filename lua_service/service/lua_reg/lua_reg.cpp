#include "lua_reg.h"
#include "iengine.h"

sol::table get_or_create_table(lua_State *L, std::string tb_name)
{
	sol::state_view lsv(L);
	sol::object v = lsv.get<sol::object>(tb_name);
	if (!v.is<sol::table>())
	{
		// 如果table不存在，那么只应该为nil，否则会有覆盖有效数据的风险
		assert(v.is<sol::nil_t>());
		lsv.create_named_table(tb_name);
	}
	return lsv[tb_name];
}

TimerCallback safe_timer_cb(sol::protected_function lua_fn)
{
	TimerCallback cb = [lua_fn]() {
		lua_fn();
	};
	return cb;
}

TimerID lua_timer_add(sol::protected_function cb_fn, int64_t start_ts_ms, int64_t execute_span_ms, int64_t execute_times)
{
	auto fn = safe_timer_cb(cb_fn);
	return timer_add(fn, start_ts_ms, execute_span_ms, execute_times);
}
TimerID lua_timer_next(sol::protected_function cb_fn, int64_t start_ts_ms)
{
	auto fn = safe_timer_cb(cb_fn);
	return timer_next(fn, start_ts_ms);
}
TimerID lua_timer_firm(sol::protected_function cb_fn, int64_t execute_span_ms, int64_t execute_times)
{
	auto fn = safe_timer_cb(cb_fn);
	return timer_firm(fn, execute_span_ms, execute_times);
}

HttpReqCnn::FnProcessRsp safe_http_req_process_rsp_cb(sol::protected_function lua_fn)
{
	HttpReqCnn::FnProcessRsp ret = [lua_fn](HttpReqCnn * self, std::string rsp_state,
		const std::unordered_map<std::string, std::string> &heads, const std::string &body, uint64_t body_len) {
lua_fn((int64_t)self->GetPtr(), rsp_state, sol::as_table(heads), body, body_len);
	};
	return ret;
}

HttpReqCnn::FnProcessEvent safe_http_req_process_event_cb(sol::protected_function lua_fn)
{
	HttpReqCnn::FnProcessEvent ret = [lua_fn](HttpReqCnn * self, HttpReqCnn::eEventType err_type, int err_num) {
		lua_fn((int64_t)self->GetPtr(), err_type, err_num);
	};
	return ret;
}

int64_t lua_http_get(const std::string &url, sol::table heads_tb, sol::protected_function rsp_fn, sol::protected_function event_fn)
{
	std::unordered_map<std::string, std::string> heads;
	lua_table_to_unorder_map(heads_tb, heads);
	auto safe_rsp_fn = safe_http_req_process_rsp_cb(rsp_fn);
	auto safe_event_fn = safe_http_req_process_event_cb(event_fn);
	return http_get(url, &heads, safe_rsp_fn, safe_event_fn);
}

int64_t lua_http_delete(const std::string &url, sol::table heads_tb, sol::protected_function rsp_fn, sol::protected_function event_fn)
{
	std::unordered_map<std::string, std::string> heads;
	lua_table_to_unorder_map(heads_tb, heads);
	auto safe_rsp_fn = safe_http_req_process_rsp_cb(rsp_fn);
	auto safe_event_fn = safe_http_req_process_event_cb(event_fn);
	return http_delete(url, &heads, safe_rsp_fn, safe_event_fn);
}

uint64_t lua_http_post(const std::string &url, sol::table heads_tb, std::string content,
	sol::protected_function rsp_fn, sol::protected_function err_fn)
{
	std::unordered_map<std::string, std::string> heads;
	lua_table_to_unorder_map(heads_tb, heads);
	auto safe_rsp_fn = safe_http_req_process_rsp_cb(rsp_fn);
	auto safe_event_fn = safe_http_req_process_event_cb(err_fn);
	return http_post(url, &heads, &content, safe_rsp_fn, safe_event_fn);
}

uint64_t lua_http_put(const std::string &url, sol::table heads_tb, std::string content,
	sol::protected_function rsp_fn, sol::protected_function err_fn)
{
	std::unordered_map<std::string, std::string> heads;
	lua_table_to_unorder_map(heads_tb, heads);
	auto safe_rsp_fn = safe_http_req_process_rsp_cb(rsp_fn);
	auto safe_event_fn = safe_http_req_process_event_cb(err_fn);
	return http_put(url, &heads, &content, safe_rsp_fn, safe_event_fn);
}

void register_native_libs(lua_State *L)
{
	sol::state_view sv(L);
	sol::table t = get_or_create_table(L, TB_NATIVE);
	lua_reg_net(L);
	lua_reg_make_shared_ptr(L);
	lua_reg_mongo(L);

	t.set_function("net_close", net_close);
	t.set_function("net_connect", net_connect);
	t.set_function("net_connect_async", net_connect_async);
	t.set_function("net_listen", net_listen);
	t.set_function("net_listen_async", net_listen_async);
	t.set_function("net_send", net_send);
	t.set_function("timer_add", lua_timer_add);
	t.set_function("timer_firm", lua_timer_firm);
	t.set_function("timer_next", lua_timer_next);
	t.set_function("timer_remove", timer_remove);

	t.set_function("logic_sec", logic_sec);
	t.set_function("logic_ms", logic_ms);
	t.set_function("delta_ms", delta_ms);

	t.set_function("http_get", lua_http_get);
	t.set_function("http_delete", lua_http_delete);
	t.set_function("http_post", lua_http_post);
	t.set_function("http_put", lua_http_put);
	t.set_function("http_cancel", http_cancel);

	t.set_function("log_debug", [](std::string log_str) { log_debug(log_str.c_str()); });
	t.set_function("log_info", [](std::string log_str) { log_info(log_str.c_str()); });
	t.set_function("log_warn", [](std::string log_str) { log_warn(log_str.c_str()); });
	t.set_function("log_error", [](std::string log_str) { log_error(log_str.c_str()); });
}

bool lua_object_to_string(sol::object lua_obj, std::string &out_str) 
{
	bool ret = false;
	switch (lua_obj.get_type())
	{
	case sol::type::string:
	{
		out_str = lua_obj.as<std::string>();
		ret = true;
	}
	break;
	case sol::type::number:
	{
		double double_val = lua_obj.as<double>();
		int64_t int64_val = (int64_t)double_val;
		if (double_val == (double)int64_val)
		{
			out_str = fmt::format("{}", int64_val);
		}
		else
		{
			out_str = fmt::format("{}", double_val);
		}
		ret = true;
	}
	break;
	case sol::type::boolean:
	{
		bool b_val = lua_obj.as<bool>();
		out_str = b_val ? "true" : "false";
		ret = true;
	}
	break;
	default:
		break;
	}
	return ret;
};

bool lua_table_to_unorder_map(sol::table tb, std::unordered_map<std::string, std::string> &uo_map)
{
	if (!tb.valid() || !tb.is<sol::table>())
		return false;

	for (auto kv_pair : tb)
	{
		const sol::object &key = kv_pair.first;
		const sol::object &val = kv_pair.second;
		std::string key_str, val_str;
		if (lua_object_to_string(key, key_str) && lua_object_to_string(val, val_str))
		{
			uo_map.insert_or_assign(key_str, val_str);
		}
	}
	return true;
}