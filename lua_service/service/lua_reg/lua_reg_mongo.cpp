#include "lua_reg.h"
#include "mongo/mongo_def.h"
#include <bsoncxx/json.hpp>
#include <rapidjson/document.h>
#include <rapidjson/stringbuffer.h>
#include <rapidjson/writer.h>
#include "iengine.h"

using const_str_ref = const std::string &;

static void Wrap_MongoTask_Handle_Result(MongoTask *task, sol::protected_function lua_fn)
{
	if (nullptr == task || !lua_fn.valid())
		return;

	const MongoReuslt &ret = task->GetResult();
	rapidjson::Document doc;
	doc.SetObject();
	rapidjson::Document::AllocatorType& doc_allocator = doc.GetAllocator();
	doc.AddMember("task_type", task->GetTaskType(), doc_allocator);
	doc.AddMember("err_num", task->GetErrNum(), doc_allocator);
	doc.AddMember("state", task->GetState(), doc_allocator);
	doc.AddMember("err_msg", rapidjson::Value(task->GetErrMsg().c_str(), task->GetErrMsg().size(), doc_allocator), doc_allocator);
	doc.AddMember("inserted_count", ret.inserted_count, doc_allocator);
	doc.AddMember("matched_count", ret.matched_count, doc_allocator);
	doc.AddMember("deleted_count", ret.deleted_count, doc_allocator);
	doc.AddMember("modified_count", ret.modified_count, doc_allocator);
	doc.AddMember("upserted_count", ret.upserted_count, doc_allocator);
	{
		rapidjson::Value arr(rapidjson::kArrayType);
		arr.SetArray();
		for (const bsoncxx::oid &item : ret.inserted_ids)
		{
			std::string id_str = item.to_string();
			arr.PushBack(rapidjson::Value(id_str.data(), id_str.size(), doc_allocator), doc_allocator);
		}
		arr.End();
		doc.AddMember("inserted_ids", arr, doc_allocator);
	}
	{
		rapidjson::Value arr(rapidjson::kArrayType);
		arr.SetArray();
		for (const bsoncxx::oid &item : ret.upserted_ids)
		{
			std::string id_str = item.to_string();
			arr.PushBack(rapidjson::Value(id_str.data(), id_str.size(), doc_allocator), doc_allocator);
		}
		arr.End();
		doc.AddMember("upserted_ids", arr, doc_allocator);
	}
	if (ret.val)
	{
		std::string val_str = bsoncxx::to_json(ret.val->view());
		doc.AddMember("val", rapidjson::Value(val_str.c_str(), val_str.size(), doc_allocator), doc_allocator);
	}
	rapidjson::StringBuffer sb;
	rapidjson::Writer<rapidjson::StringBuffer> sb_writer(sb);
	doc.Accept(sb_writer);
	std::string ret_str(sb.GetString(), sb.GetSize());
	
	log_debug("Wrap_MongoTask_Handle_Result {}", ret_str);
	lua_fn(ret_str);
}

static bool Wrap_MongoTaskMgr_FindOne(MongoTaskMgr &mgr, uint32_t hash_code, const_str_ref db_name, const_str_ref coll_name,
	const_str_ref filter_str, const_str_ref opt_str, sol::protected_function lua_cb_fn)
{
	bsoncxx::document::value fiter = bsoncxx::from_json(filter_str);
	bsoncxx::document::value opt = bsoncxx::from_json(opt_str);
	MongoTask::ResultCbFn cb_fn = std::bind(Wrap_MongoTask_Handle_Result, std::placeholders::_1, lua_cb_fn);
	return mgr.FindOne(hash_code, db_name, coll_name, fiter.view(), opt.view(), cb_fn);
}

static bool Wrap_MongoTaskMgr_InsertOne(MongoTaskMgr &mgr, uint32_t hash_code, const_str_ref db_name, const_str_ref coll_name,
	const_str_ref content_str, const_str_ref opt_str, sol::protected_function lua_cb_fn)
{
	bsoncxx::document::value content = bsoncxx::from_json(content_str);
	bsoncxx::document::value opt = bsoncxx::from_json(opt_str);
	MongoTask::ResultCbFn cb_fn = std::bind(Wrap_MongoTask_Handle_Result, std::placeholders::_1, lua_cb_fn);
	return mgr.InsertOne(hash_code, db_name, coll_name, content.view(), opt.view(), cb_fn);
}

static bool Wrap_MongoTaskMgr_DeleteOne(MongoTaskMgr &mgr, uint32_t hash_code, const_str_ref db_name, const_str_ref coll_name,
	const_str_ref filter_str, const_str_ref opt_str, sol::protected_function lua_cb_fn)
{
	bsoncxx::document::value fiter = bsoncxx::from_json(filter_str);
	bsoncxx::document::value opt = bsoncxx::from_json(opt_str);
	MongoTask::ResultCbFn cb_fn = std::bind(Wrap_MongoTask_Handle_Result, std::placeholders::_1, lua_cb_fn);
	return mgr.DeleteOne(hash_code, db_name, coll_name, fiter.view(), opt.view(), cb_fn);
}

static bool Wrap_MongoTaskMgr_UpdateOne(MongoTaskMgr &mgr, uint32_t hash_code, const_str_ref db_name, const_str_ref coll_name,
	const_str_ref filter_str, const_str_ref content_str, const_str_ref opt_str, sol::protected_function lua_cb_fn)
{
	bsoncxx::document::value fiter = bsoncxx::from_json(filter_str);
	bsoncxx::document::value content = bsoncxx::from_json(content_str);
	bsoncxx::document::value opt = bsoncxx::from_json(opt_str);
	MongoTask::ResultCbFn cb_fn = std::bind(Wrap_MongoTask_Handle_Result, std::placeholders::_1, lua_cb_fn);
	return mgr.UpdateOne(hash_code, db_name, coll_name, fiter.view(), content.view(), opt.view(), cb_fn);
}

static bool Wrap_MongoTaskMgr_ReplaceOne(MongoTaskMgr &mgr, uint32_t hash_code, const_str_ref db_name, const_str_ref coll_name,
	const_str_ref filter_str, const_str_ref content_str, const_str_ref opt_str, sol::protected_function lua_cb_fn)
{
	bsoncxx::document::value fiter = bsoncxx::from_json(filter_str);
	bsoncxx::document::value content = bsoncxx::from_json(content_str);
	bsoncxx::document::value opt = bsoncxx::from_json(opt_str);
	MongoTask::ResultCbFn cb_fn = std::bind(Wrap_MongoTask_Handle_Result, std::placeholders::_1, lua_cb_fn);
	return mgr.ReplaceOne(hash_code, db_name, coll_name, fiter.view(), content.view(), opt.view(), cb_fn);
}

void lua_reg_mongo(lua_State *L)
{
	sol::table native_tb = get_or_create_table(L, TB_NATIVE);
	{
		{
			// MongoTaskMgr
			std::string class_name = "MongoTaskMgr";
			sol::object v = native_tb.raw_get_or(class_name, sol::lua_nil);
			assert(!v.valid());
			sol::usertype<MongoTaskMgr> meta_table(
				"start", &MongoTaskMgr::Start,
				"stop", &MongoTaskMgr::Stop,
				"on_frame", &MongoTaskMgr::OnFrame,
				"find_one", Wrap_MongoTaskMgr_FindOne,
				"insert_one", Wrap_MongoTaskMgr_InsertOne,
				"delete_one", Wrap_MongoTaskMgr_DeleteOne,
				"update_one", Wrap_MongoTaskMgr_UpdateOne,
				"replace_one", Wrap_MongoTaskMgr_ReplaceOne
			);
			native_tb.set_usertype(class_name, meta_table);
		}
	}
}