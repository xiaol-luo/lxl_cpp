#pragma once

#include <bsoncxx/document/value.hpp>
#include <vector>
#include <stdint.h>
#include "bsoncxx/oid.hpp"

struct MongoReuslt
{
	~MongoReuslt()
	{
		delete val; val = nullptr;
	}

	uint64_t inserted_count = 0;
	std::vector<bsoncxx::oid> inserted_ids;
	uint64_t matched_count = 0;
	uint64_t modified_count = 0;
	uint64_t deleted_count = 0;
	uint64_t upserted_count = 0;
	std::vector<bsoncxx::oid> upserted_ids;
	bsoncxx::document::value *val = nullptr;
};
