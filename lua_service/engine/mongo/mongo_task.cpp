#include "mongo_task.h"
#include <mongocxx/exception/exception.hpp>
#include <iengine.h>

MongoTask::MongoTask(eMongoTask task_type, const std::string & db_name, const std::string & coll_name, const bsoncxx::document::view_or_value & filter, const bsoncxx::document::view_or_value & content, const bsoncxx::document::view_or_value & opt, ResultCbFn cb_fn)
{
}

MongoTask::MongoTask(eMongoTask task_type, const std::string & db_name, const std::string & coll_name, const bsoncxx::document::view_or_value & filter, const std::vector<bsoncxx::document::view_or_value>& contents, const bsoncxx::document::view_or_value & opt, ResultCbFn cb_fn)
{
}

MongoTask::~MongoTask()
{
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
		auto builder = bsoncxx::builder::stream::document();
		bsoncxx::document::value doc_value = builder
			<< "name" << "MongoDB"
			<< "type" << "database"
			<< "count" << 1
			<< "versions" << bsoncxx::builder::stream::open_array
			<< "v3.2" << "v3.0" << "v2.6"
			<< bsoncxx::builder::stream::close_array
			<< "info" << bsoncxx::builder::stream::open_document
			<< "x" << 203
			<< "y" << 102
			<< bsoncxx::builder::stream::close_document
			<< bsoncxx::builder::stream::finalize;

		mongocxx::collection test_coll = client["test"]["test_coll"];
		bsoncxx::stdx::optional<mongocxx::result::insert_one> result = test_coll.insert_one(doc_value.view());
		if (result)
		{
			log_debug("inserted int to test.test_coll {}", result->inserted_id().get_oid().value.to_string());
		}
	}
	catch (mongocxx::exception & ex)
	{
		m_err_num = ex.code().value();
		m_err_msg = ex.what();
		log_error("create mongo pool fail {} {}", m_err_num, m_err_msg);
	}	
}

void MongoTask::HandleResult()
{
}
