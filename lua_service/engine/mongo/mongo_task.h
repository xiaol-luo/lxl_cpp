#pragma once

#include <stdint.h>
#include <functional>
#include <bsoncxx/document/value.hpp>
#include <bsoncxx/document/view_or_value.hpp>
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
	eMongoTask_FindMany,
	eMongoTask_InsertOne,
	eMongoTask_InsertMany,
	eMongoTask_UpdateOne,
	eMongoTask_UpdateMany,
	eMongoTask_DeleteOne,
	eMongoTask_DeleteMany,

	eMongoTask_Count,
};

class MongoTask
{
public:
	using ResultCbFn = std::function<void(MongoTask *, void *)>;
public:
	MongoTask(eMongoTask task_type, bsoncxx::document::view_or_value filter, bsoncxx::document::view_or_value content, bsoncxx::document::view_or_value opt, ResultCbFn cb_fn);
	~MongoTask();

	void Process();
	void HandleResult();

	eMongoTaskState GetState() { return m_state; }
	int GetErrNum() { return m_err_num; }
	const std::string & GetErrMsg() { return m_err_msg; }
	eMongoTask GetTaskType() { return m_task_type; }
	const MongoReuslt & GetResult() { return m_result; }

protected:
	eMongoTaskState m_state = eMongoTaskState_Count;
	int m_err_num = 0;
	std::string m_err_msg;
	eMongoTask m_task_type = eMongoTask_Count;
	bsoncxx::document::value *m_filter = nullptr;
	bsoncxx::document::value *m_content = nullptr;
	bsoncxx::document::value *m_opt = nullptr;
	ResultCbFn m_cb_fn = nullptr;
	void *m_cb_fn_param = nullptr;
	MongoReuslt m_result;
};
