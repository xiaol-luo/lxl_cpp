#include "mongo_task.h"
#include <mongocxx/exception/exception.hpp>
#include <iengine.h>
#include "mongo_def.h"

#define SetOptHelp(field_name, filed_type, field_type_fn, set_field_fn) \
{\
	auto bson_elem = view[field_name];\
	if (bson_elem && bsoncxx::type::filed_type == bson_elem.type())\
	{\
		auto elem_val = bson_elem.field_type_fn().value;\
		ret.set_field_fn(elem_val);\
	}\
}

mongocxx::options::find MongoTask::GenFindOpt(const bsoncxx::document::view & view)
{
	mongocxx::options::find ret;
	{
		ret.max_time(std::chrono::milliseconds(10 * 1000));
		auto bson_elem = view[MOFN_MAX_TIME];
		if (bson_elem && bsoncxx::type::k_int32 == bson_elem.type())
		{
			int elem_val = bson_elem.get_int32().value;
			ret.max_time(std::chrono::milliseconds(elem_val));
		}
	}
	SetOptHelp(MOFN_PROJECTION, k_document, get_document, projection);
	SetOptHelp(MOFN_SORT, k_document, get_document, sort);
	SetOptHelp(MOFN_LIMIT, k_int32, get_int32, limit);
	SetOptHelp(MOFN_SKIP, k_int32, get_int32, skip);
	SetOptHelp(MOFN_MIN, k_document, get_document, min);
	SetOptHelp(MOFN_MAX, k_document, get_document, max);
	return ret;
}

mongocxx::options::insert MongoTask::GenInsertOpt(const bsoncxx::document::view & view)
{
	return mongocxx::options::insert();
}

mongocxx::options::delete_options MongoTask::GenDeleteOpt(const bsoncxx::document::view & view)
{
	return mongocxx::options::delete_options();
}

mongocxx::options::update MongoTask::GenUpdateOpt(const bsoncxx::document::view & view)
{
	mongocxx::options::update ret;
	SetOptHelp(MOFN_UPSERT, k_bool, get_bool, upsert);
	return ret;
}

mongocxx::options::count MongoTask::GenCountOpt(const bsoncxx::document::view & view)
{
	return mongocxx::options::count();
}

mongocxx::options::find_one_and_delete MongoTask::GenFindOneAndDeleteOpt(const bsoncxx::document::view & view)
{
	return mongocxx::options::find_one_and_delete();
}

mongocxx::options::find_one_and_update MongoTask::GenFindOneAndUpdateOpt(const bsoncxx::document::view & view)
{
	mongocxx::options::find_one_and_update ret;
	{
		auto bson_elem = view[MOFN_PROJECTION];
		ret.max_time(std::chrono::milliseconds(10 * 1000));
		if (bson_elem && bsoncxx::type::k_document == bson_elem.type())
		{
			auto elem_val = bson_elem.get_document().value;
			ret.projection(elem_val);
		}
	}
	SetOptHelp(MOFN_UPSERT, k_bool, get_bool, upsert);
	return ret;
}

mongocxx::options::find_one_and_replace MongoTask::GenFindOneAndReplaceOpt(const bsoncxx::document::view & view)
{
	return mongocxx::options::find_one_and_replace();
}

