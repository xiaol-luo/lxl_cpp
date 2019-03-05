#pragma once

#include <bsoncxx/builder/basic/document.hpp>
#include "mongo_task.h"
#include "mongo_task_mgr.h"
#include "mongo_result.h"

// MOFN --> mongo optional field name
const static char * MOFN_MAX_TIME = "max_time";
const static char * MOFN_PROJECTION = "projection";
const static char * MOFN_UPSERT = "upsert";
const static char * MOFN_SORT = "sort";
const static char * MOFN_LIMIT = "limit";
const static char * MOFN_MIN = "min";
const static char * MOFN_MAX = "max";
const static char * MOFN_SKIP = "skip";