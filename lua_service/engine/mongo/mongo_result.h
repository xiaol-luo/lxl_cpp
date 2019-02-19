#pragma once

#include <bsoncxx/document/value.hpp>
#include <vector>
#include <stdint.h>
#include "bsoncxx/oid.hpp"

struct MongoReuslt
{
	int32_t inserted_count = 0;
	std::vector<bsoncxx::oid> inserted_ids;
	int32_t matched_count = 0;
	int32_t modified_count = 0;
	int32_t deleted_count = 0;
	int32_t upserted_count = 0;
	std::vector<bsoncxx::oid> upserted_ids;
	bsoncxx::document::value *val = nullptr;
// 	mongocxx::result::bulk_write xx;

};
