#include "lua_reg.h"
#include "redis/redis_task_mgr.h"
#include "redis/redis_def.h"

static void RedisReplyFillLuaTable(sol::table tb, redisReply *reply)
{
	/*
	tb.add("result", ret);
	ret.add("type", task->reply->type);
	ret.add("value", task->reply->element)
	*/
}

static void Wrap_Handle_Result(RedisTask *task, sol::main_protected_function lua_fn)
{
	if (nullptr == task || !lua_fn.valid())
		return;

	sol::state_view st(lua_fn.lua_state());
	sol::table tb = st.create_table();
	tb.add("task_id", task->task_id);
	tb.add("error_num", task->error_num);
	tb.add("error_msg", task->error_msg);
	if (task->reply)
	{
		sol::table ret = st.create_table();
	}
	lua_fn(tb);
}

static uint64_t Wrap_Execute_Cmd(RedisTaskMgr &mgr, uint32_t hash_code, sol::main_protected_function lua_cb_fn, std::string cmd)
{
	return 0;
}

static uint64_t Wrap_Execute_Cmd_Binary_Safe(RedisTaskMgr &mgr, uint32_t hash_code, sol::main_protected_function lua_cb_fn, 
	std::string cmd_format, std::vector<std::string> param_list)
{
	return 0;
}

static uint64_t Wrap_Execute_Cmd_Array(RedisTaskMgr &mgr, uint32_t hash_code, sol::main_protected_function lua_cb_fn, std::vector<std::string> cmd_array)
{
	return 0;
}

void lua_reg_redis(lua_State *L)
{
	/*
	// RedisTaskMgr
	std::string class_name = "RedisTaskMgr";
	sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
	assert(!v.valid());
	sol::usertype<RedisTaskMgr> meta_table(
		"start", &RedisTaskMgr::Start,
		"stop", &RedisTaskMgr::Stop,
		"on_frame", &RedisTaskMgr::OnFrame,
		"command", &Wrap_Execute_Cmd,
		"bin_command", &Wrap_Execute_Cmd_Binary_Safe,
		"array_command", &Wrap_Execute_Cmd_Array
	);
	native_tb.set_usertype(class_name, meta_table);
	*/
}
