#include "lua_reg.h"
#include "redis/redis_task_mgr.h"
#include "redis/redis_def.h"

static sol::table RedisReplyToLuaTable(sol::state_view st, redisReply *reply)
{
	sol::table tb = st.create_table();
	tb.set("type", reply->type);

	switch (reply->type)
	{
	case REDIS_REPLY_ERROR:
	case REDIS_REPLY_STATUS:
	case REDIS_REPLY_STRING:
	{
		tb.set("value", std::string(reply->str, reply->len));
	}
	break;
	case REDIS_REPLY_INTEGER:
	{
		tb.set("value", reply->integer);
	}
	break;
	case REDIS_REPLY_ARRAY:
	{
		sol::table value_tb = st.create_table();
		tb.set("value", value_tb);
		for (size_t i = 0; i < reply->elements; ++i)
		{
			sol::table elem_tb = RedisReplyToLuaTable(st, reply->element[i]);
			value_tb.add(elem_tb);
		}
	}
	break;
	case REDIS_REPLY_NIL:
	{
		// DO NOTHING
	}
	break;
	default:
		break;
	}
	return tb;
}

static void Wrap_Handle_Result(RedisTask *task, sol::main_protected_function lua_fn)
{
	if (nullptr == task || !lua_fn.valid())
		return;

	sol::state_view st(lua_fn.lua_state());
	sol::table tb = st.create_table();
	tb.set("task_id", task->task_id);
	tb.set("error_num", task->error_num);
	tb.set("error_msg", task->error_msg);
	if (task->reply)
	{
		if (0 == task->error_num && REDIS_REPLY_ERROR == task->reply->type)
		{
			tb.set("error_num", task->error_num);
			tb.set("error_msg", std::string(task->reply->str, task->reply->len));
		}
		sol::table reply = RedisReplyToLuaTable(st, task->reply);
		tb.set("reply", reply);
	}
	lua_fn(tb);
}

static uint64_t Wrap_Execute_Cmd(RedisTaskMgr &mgr, uint64_t hash_code, sol::main_protected_function lua_cb_fn, std::string cmd)
{
	RedisTaskCallback cb = std::bind(Wrap_Handle_Result, std::placeholders::_1, lua_cb_fn);
	return mgr.ExecuteCmd(hash_code, cb, cmd);
}

static uint64_t Wrap_Execute_Cmd_Binary_Safe(RedisTaskMgr &mgr, uint64_t hash_code, sol::main_protected_function lua_cb_fn,
	std::string cmd_format, std::vector<std::string> param_list)
{
	RedisTaskCallback cb = std::bind(Wrap_Handle_Result, std::placeholders::_1, lua_cb_fn);
	return mgr.ExecuteCmdBinFormat(hash_code, cb, cmd_format, param_list);
}

static uint64_t Wrap_Execute_Cmd_Array(RedisTaskMgr &mgr, uint64_t hash_code, sol::main_protected_function lua_cb_fn, std::vector<std::string> cmd_array)
{
	RedisTaskCallback cb = std::bind(Wrap_Handle_Result, std::placeholders::_1, lua_cb_fn);
	return mgr.ExecuteCmdArgv(hash_code, cb, cmd_array);
}

void lua_reg_redis(lua_State *L)
{
	sol::main_table native_tb = get_or_create_table(L, TB_NATIVE);
	// RedisTaskMgr
	std::string class_name = "RedisTaskMgr";
	sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
	assert(!v.valid());
	sol::usertype<RedisTaskMgr> meta_table(
		"start", &RedisTaskMgr::Start,
		"stop", &RedisTaskMgr::Stop,
		"on_frame", &RedisTaskMgr::OnFrame,
		"command", &Wrap_Execute_Cmd,
		"binary_command", &Wrap_Execute_Cmd_Binary_Safe,
		"array_command", &Wrap_Execute_Cmd_Array
	);
	native_tb.set_usertype(class_name, meta_table);
}
