#include "mongo_task.h"
#include <mongocxx/exception/exception.hpp>
#include <iengine.h>
#include "mongo_def.h"

MongoTask::MongoTask(eMongoTask task_type, const std::string & db_name, const std::string & coll_name, const bsoncxx::document::view_or_value & filter, const bsoncxx::document::view_or_value & content, const bsoncxx::document::view_or_value & opt, ResultCbFn cb_fn)
{
	m_task_type = task_type;
	m_db_name = db_name;
	m_coll_name = coll_name;
	m_filter = new bsoncxx::document::value(filter);
	m_opt = new bsoncxx::document::value(opt);
	m_content = new bsoncxx::document::value(content);
	m_cb_fn = cb_fn;
	m_state = eMongoTaskState_Ready;
}

MongoTask::MongoTask(eMongoTask task_type, const std::string & db_name, const std::string & coll_name, const bsoncxx::document::view_or_value & filter, const std::vector<bsoncxx::document::view_or_value>& contents, const bsoncxx::document::view_or_value & opt, ResultCbFn cb_fn)
{
	m_task_type = task_type;
	m_db_name = db_name;
	m_coll_name = coll_name;
	m_filter = new bsoncxx::document::value(filter);
	m_opt = new bsoncxx::document::value(opt);
	for (auto &&item : contents)
	{
		bsoncxx::document::value val(item);
		m_content_vec.push_back(std::move(val));
	}
	m_cb_fn = cb_fn;
	m_state = eMongoTaskState_Ready;
}

MongoTask::~MongoTask()
{
	delete m_filter; m_filter = nullptr;
	delete m_opt; m_opt = nullptr;
	delete m_content; m_content = nullptr;
}

#include <mongocxx/client.hpp>
#include <mongocxx/database.hpp>
#include <mongocxx/uri.hpp>
#include <mongocxx/instance.hpp>
#include <bsoncxx/builder/stream/document.hpp>
#include <bsoncxx/oid.hpp>

void MongoTask::Process(mongocxx::client & client)
{
	try
	{
		m_state = eMongoTaskState_Processing;
		switch (m_task_type)
		{
		case eMongoTask_FindOne:
			DoTask_FindOne(client);
			break;
		case eMongoTask_FindMany:
			DoTask_FindMany(client);
			break;
		case eMongoTask_InsertOne:
			DoTask_InsertOne(client);
			break;
		case eMongoTask_InsertMany:
			DoTask_InsertMany(client);
			break;
		case eMongoTask_UpdateOne:
			DoTask_UpdateOne(client);
			break;
		case eMongoTask_UpdateMany:
			DoTask_UpdateMany(client);
			break;
		case eMongoTask_DeleteOne:
			DoTask_DeleteOne(client);
			break;
		case eMongoTask_DeleteMany:
			DoTask_DeleteMany(client);
			break;
		case eMongoTask_FindOneAndDelete:
			DoTask_FindOneAndDelete(client);
			break;
		case eMongoTask_FindOneAndReplace:
			DoTask_FindOneAndReplace(client);
			break;
		case eMongoTask_FindOneAndUpdate:
			DoTask_FindOneAndUpdate(client);
			break;
		case eMongoTask_CountDocuments:
			DoTask_CountDocuments(client);
			break;
		default:
			break;
		}
	}
	catch (mongocxx::exception & ex)
	{
		m_err_num = ex.code().value();
		m_err_msg = ex.what();
		log_error("MongoTask::Process fail task_type:{}, task_id:{}, db:{}, coll:{} err_num:{}, err_msg:{}", m_task_type, m_id, m_db_name, m_coll_name, m_err_num, m_err_msg);
	}	
	m_state = eMongoTaskState_Done;
}

void MongoTask::HandleResult()
{
	if (nullptr != m_cb_fn)
	{
		m_cb_fn(this);
	}
}

mongocxx::collection MongoTask::GetColl(mongocxx::client & client)
{
	mongocxx::database db = client.database(m_db_name);
	mongocxx::collection coll = db.collection(m_coll_name);
	return coll;
}

void MongoTask::DoTask_FindOne(mongocxx::client & client)
{
	mongocxx::collection coll = this->GetColl(client);
	mongocxx::options::find opt = GenFindOpt(m_opt->view());
	bsoncxx::builder::basic::array builder;
	mongocxx::stdx::optional<bsoncxx::document::value> ret = coll.find_one(m_filter->view(), opt);
	if (ret)
	{
		m_result.matched_count = 1;
		builder.append(std::move(bsoncxx::document::value(*ret)));
	}
	m_result.val = new bsoncxx::document::value(builder.view());
}

void MongoTask::DoTask_InsertOne(mongocxx::client & client)
{
	mongocxx::collection coll = this->GetColl(client);
	mongocxx::options::insert opt = GenInsertOpt(m_opt->view());
	auto ret = coll.insert_one(m_content->view(), opt);
	if (ret)
	{
		m_result.inserted_count = 1;
		m_result.inserted_ids.push_back(ret->inserted_id().get_oid().value);
	}
}

void MongoTask::DoTask_DeleteOne(mongocxx::client & client)
{
	mongocxx::collection coll = this->GetColl(client);
	mongocxx::options::delete_options opt = GenDeleteOpt(m_opt->view());
	mongocxx::stdx::optional<mongocxx::result::delete_result> ret = coll.delete_one(m_filter->view(), opt);
	if (ret)
	{
		m_result.deleted_count = ret->deleted_count();
	}
}

void MongoTask::DoTask_UpdateOne(mongocxx::client & client)
{
	mongocxx::collection coll = this->GetColl(client);
	mongocxx::options::update opt = GenUpdateOpt(m_opt->view());
	mongocxx::stdx::optional<mongocxx::result::update> ret = coll.update_one(m_filter->view(), m_content->view(), opt);
	if (ret)
	{
		m_result.matched_count = ret->matched_count();
		m_result.modified_count = ret->modified_count();
		mongocxx::stdx::optional<bsoncxx::document::element> upserted_ids = ret->upserted_id();
		if (upserted_ids)
		{
			m_result.upserted_ids.push_back(upserted_ids->get_oid().value);
		}
	}
}

void MongoTask::DoTask_FindMany(mongocxx::client & client)
{
	mongocxx::collection coll = this->GetColl(client);
	mongocxx::options::find opt = GenFindOpt(m_opt->view());
	mongocxx::cursor ret = coll.find(m_filter->view(), opt);
	bsoncxx::builder::basic::array builder;
	for (mongocxx::cursor::iterator it = ret.begin(); it != ret.end(); ++it)
	{
		++m_result.matched_count;
		builder.append(bsoncxx::document::value(*it));
	}
	m_result.val = new bsoncxx::document::value(builder.view());
}

void MongoTask::DoTask_UpdateMany(mongocxx::client & client)
{
	mongocxx::collection coll = this->GetColl(client);
	mongocxx::options::update opt = GenUpdateOpt(m_opt->view());
	mongocxx::stdx::optional<mongocxx::result::update> ret = coll.update_many(m_filter->view(), m_content->view(), opt);
	if (ret)
	{
		m_result.matched_count = ret->matched_count();
		m_result.modified_count = ret->modified_count();
		mongocxx::stdx::optional<bsoncxx::document::element> upserted_ids = ret->upserted_id();
		if (upserted_ids)
		{
			m_result.upserted_ids.push_back(upserted_ids->get_oid().value);
		}
	}
}

void MongoTask::DoTask_InsertMany(mongocxx::client & client)
{
	mongocxx::collection coll = this->GetColl(client);
	mongocxx::options::insert opt = GenInsertOpt(m_opt->view());

	mongocxx::stdx::optional<mongocxx::result::insert_many> ret = coll.insert_many(m_content_vec, opt);
	if (ret)
	{
		m_result.inserted_count = ret->inserted_ids().size();
		for (auto &&item : ret->inserted_ids())
		{
			m_result.inserted_ids.push_back(item.second.get_oid().value);
		}
	}
}

void MongoTask::DoTask_DeleteMany(mongocxx::client & client)
{
	mongocxx::collection coll = this->GetColl(client);
	mongocxx::options::delete_options opt = GenDeleteOpt(m_opt->view());
	mongocxx::stdx::optional<mongocxx::result::delete_result> ret = coll.delete_many(m_filter->view(), opt);
	if (ret)
	{
		m_result.deleted_count = ret->deleted_count();
	}
}

void MongoTask::DoTask_FindOneAndDelete(mongocxx::client & client)
{
	mongocxx::collection coll = this->GetColl(client);
	mongocxx::options::find_one_and_delete opt = GenFindOneAndDeleteOpt(m_opt->view());
	mongocxx::stdx::optional<bsoncxx::document::value> ret = coll.find_one_and_delete(m_filter->view(), opt);
	if (ret)
	{
		m_result.matched_count = 1;
		m_result.deleted_count = 1;
		m_result.val = new bsoncxx::document::value(ret->view());
	}
}

void MongoTask::DoTask_FindOneAndReplace(mongocxx::client & client)
{
	mongocxx::collection coll = this->GetColl(client);
	mongocxx::options::find_one_and_replace opt = GenFindOneAndReplaceOpt(m_opt->view());
	mongocxx::stdx::optional<bsoncxx::document::value> ret = coll.find_one_and_replace(m_filter->view(), m_content->view(), opt);
	if (ret)
	{
		m_result.matched_count = 1;
		m_result.modified_count = 1;
		m_result.val = new bsoncxx::document::value(ret->view());
	}
}

void MongoTask::DoTask_FindOneAndUpdate(mongocxx::client & client)
{
	mongocxx::collection coll = this->GetColl(client);
	mongocxx::options::find_one_and_update opt = GenFindOneAndUpdateOpt(m_opt->view());
	mongocxx::stdx::optional<bsoncxx::document::value> ret = coll.find_one_and_update(m_filter->view(), m_content->view(), opt);
	if (ret)
	{
		m_result.matched_count = 1;
		m_result.modified_count = 1;
		m_result.val = new bsoncxx::document::value(ret->view());
	}
}

void MongoTask::DoTask_CountDocuments(mongocxx::client & client)
{
	mongocxx::collection coll = this->GetColl(client);
	mongocxx::options::count opt = GenCountOpt(m_opt->view());
	bsoncxx::builder::basic::array builder;
#ifdef WIN32
	m_result.matched_count = coll.count(m_filter->view(), opt);
#else
	m_result.matched_count = coll.count_documents(m_filter->view(), opt);
#endif
}

