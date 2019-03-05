#include "mongo_task.h"
#include <mongocxx/exception/exception.hpp>
#include <iengine.h>
#include "mongo_def.h"

mongocxx::options::find MongoTask::GenFindOpt(bsoncxx::document::view & view)
{
	mongocxx::options::find ret;
	{
		auto bson_elem = view[MOFN_MAX_TIME];
		ret.max_time(std::chrono::milliseconds(10 * 1000));
		if (bson_elem && bsoncxx::type::k_int32 == bson_elem.type())
		{
			int elem_val = bson_elem.get_int32().value;
			ret.max_time(std::chrono::milliseconds(elem_val));
		}
	}
	{
		auto bson_elem = view[MOFN_PROJECTION];
		ret.max_time(std::chrono::milliseconds(10 * 1000));
		if (bson_elem && bsoncxx::type::k_document == bson_elem.type())
		{
			auto elem_val = bson_elem.get_document().value;
			ret.projection(elem_val);
		}
	}
	return ret;
}

mongocxx::options::insert MongoTask::GenInsertOpt(bsoncxx::document::view & view)
{
	return mongocxx::options::insert();
}

mongocxx::options::delete_options MongoTask::GenDeleteOpt(bsoncxx::document::view & view)
{
	return mongocxx::options::delete_options();
}

mongocxx::options::update MongoTask::GenUpdateOpt(bsoncxx::document::view & view)
{
	mongocxx::options::update ret;
	{
		auto bson_elem = view[MOFN_UPSERT];
		if (bson_elem && bsoncxx::type::k_bool == bson_elem.type())
		{
			auto elem_val = bson_elem.get_bool().value;
			ret.upsert(elem_val);
		}
	}
	return ret;
}

mongocxx::options::count MongoTask::GenCountOpt(bsoncxx::document::view & view)
{
	return mongocxx::options::count();
}

mongocxx::options::find_one_and_delete MongoTask::GenFindOneAndDeleteOpt(bsoncxx::document::view & view)
{
	return mongocxx::options::find_one_and_delete();
}

mongocxx::options::find_one_and_update MongoTask::GenFindOneAndUpdateOpt(bsoncxx::document::view & view)
{
	mongocxx::options::find_one_and_update ret;
	{
		auto bson_elem = view[MOFN_UPSERT];
		if (bson_elem && bsoncxx::type::k_bool == bson_elem.type())
		{
			auto elem_val = bson_elem.get_bool().value;
			ret.upsert(elem_val);
		}
	}
	{
		auto bson_elem = view[MOFN_PROJECTION];
		ret.max_time(std::chrono::milliseconds(10 * 1000));
		if (bson_elem && bsoncxx::type::k_document == bson_elem.type())
		{
			auto elem_val = bson_elem.get_document().value;
			ret.projection(elem_val);
		}
	}
	return ret;
}

mongocxx::options::find_one_and_replace MongoTask::GenFindOneAndReplaceOpt(bsoncxx::document::view & view)
{
	return mongocxx::options::find_one_and_replace();
}

