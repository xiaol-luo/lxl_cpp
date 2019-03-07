#pragma once

#include <stdint.h>
#include <functional>
#include <bsoncxx/document/value.hpp>
#include <bsoncxx/document/view_or_value.hpp>
#include <mongocxx/client.hpp>
#include "mongo_result.h"

enum eMongoTaskState
{
	eMongoTaskState_Ready,
	eMongoTaskState_Processing,
	eMongoTaskState_Done,
	eMongoTaskState_Count,
};

enum eMongoTask
{
	eMongoTask_FindOne,
	eMongoTask_InsertOne,
	eMongoTask_UpdateOne,
	eMongoTask_DeleteOne,

	eMongoTask_FindMany,
	eMongoTask_InsertMany,
	eMongoTask_UpdateMany,
	eMongoTask_DeleteMany,

	eMongoTask_FindOneAndDelete,
	eMongoTask_FindOneAndReplace,
	eMongoTask_FindOneAndUpdate,
	eMongoTask_CountDocuments,

	eMongoTask_Count,
};

class MongoTask
{
public:
	using ResultCbFn = std::function<void(MongoTask *)>;
public:
	MongoTask(eMongoTask task_type, const std::string &db_name, const std::string &coll_name, const bsoncxx::document::view_or_value &filter, const bsoncxx::document::view_or_value &content,
		const bsoncxx::document::view_or_value &opt, ResultCbFn cb_fn);
	MongoTask(eMongoTask task_type, const std::string &db_name, const std::string &coll_name, const bsoncxx::document::view_or_value &filter,
		const std::vector<bsoncxx::document::view_or_value> &contents, const bsoncxx::document::view_or_value &opt, ResultCbFn cb_fn);
	~MongoTask();

	void Process(mongocxx::client &client);
	void HandleResult();

	void SetId(uint64_t id) { m_id = id; }
	uint64_t GetId() { return m_id; }
	eMongoTaskState GetState() { return m_state; }
	int GetErrNum() { return m_err_num; }
	const std::string & GetErrMsg() { return m_err_msg; }
	eMongoTask GetTaskType() { return m_task_type; }
	const MongoReuslt & GetResult() { return m_result; }

protected:
	eMongoTaskState m_state = eMongoTaskState_Count;
	uint64_t m_id = 0;
	int m_err_num = 0;
	std::string m_err_msg;
	eMongoTask m_task_type = eMongoTask_Count;
	std::string m_db_name;
	std::string m_coll_name;
	bsoncxx::document::value *m_filter = nullptr;
	bsoncxx::document::value *m_content = nullptr;
	bsoncxx::document::value *m_opt = nullptr;
	std::vector<bsoncxx::document::value> m_content_vec;
	ResultCbFn m_cb_fn = nullptr;
	MongoReuslt m_result;

public:
	static mongocxx::options::find GenFindOpt(const bsoncxx::document::view &view);
	static mongocxx::options::insert GenInsertOpt(const bsoncxx::document::view &view);
	static mongocxx::options::delete_options GenDeleteOpt(const bsoncxx::document::view &view);
	static mongocxx::options::update GenUpdateOpt(const bsoncxx::document::view &view);
	static mongocxx::options::count GenCountOpt(const bsoncxx::document::view &view);
	static mongocxx::options::find_one_and_delete GenFindOneAndDeleteOpt(const bsoncxx::document::view &view);
	static mongocxx::options::find_one_and_update GenFindOneAndUpdateOpt(const bsoncxx::document::view &view);
	static mongocxx::options::find_one_and_replace GenFindOneAndReplaceOpt(const bsoncxx::document::view &view);

protected:
	mongocxx::collection GetColl(mongocxx::client & client);
	void DoTask_FindOne(mongocxx::client &client);
	void DoTask_InsertOne(mongocxx::client &client);
	void DoTask_DeleteOne(mongocxx::client &client);
	void DoTask_UpdateOne(mongocxx::client &client);

	void DoTask_FindMany(mongocxx::client &client);
	void DoTask_UpdateMany(mongocxx::client &client);
	void DoTask_InsertMany(mongocxx::client &client);
	void DoTask_DeleteMany(mongocxx::client &client);

	void DoTask_FindOneAndDelete(mongocxx::client &client);
	void DoTask_FindOneAndReplace(mongocxx::client &client);
	void DoTask_FindOneAndUpdate(mongocxx::client &client);
	void DoTask_CountDocuments(mongocxx::client &client);
};
