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

void register_native_libs(lua_State *L)
{
	sol::state_view sv(L);
	sol::table t = get_or_create_table(L, TB_NATIVE);
	lua_reg_net(L);
	lua_reg_make_shared_ptr(L);

	t.set_function("net_close", net_close);
	t.set_function("net_connect", net_connect);
	t.set_function("net_connect_async", net_connect_async);
	t.set_function("net_listen", net_listen);
	t.set_function("net_listen_async", net_listen_async);
	t.set_function("net_send", net_send);
	t.set_function("timer_add", timer_add);
	t.set_function("timer_firm", timer_firm);
	t.set_function("timer_next", timer_next);

	t.set_function("http_get", sol::overload(
		[](std::string url, HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent err_cb) { return http_get(url, rsp_cb, err_cb); },
		[](std::string url, std::unordered_map<std::string, std::string> heads,	HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent err_cb) 
			{ return http_get(url, heads, rsp_cb, err_cb); }
	));
	t.set_function("http_post", sol::overload(
		[](std::string url, HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent err_cb) { return http_post(url, rsp_cb, err_cb); },
		[](std::string url, std::unordered_map<std::string, std::string> heads, std::string content,
			HttpReqCnn::FnProcessRsp rsp_cb, HttpReqCnn::FnProcessEvent err_cb)
				{ return http_post(url, heads, content, rsp_cb, err_cb); }
	));
	t.set_function("http_cancel", http_cancel);
}