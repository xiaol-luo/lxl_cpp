#include "mongo_task.h"

MongoTask::MongoTask(eMongoTask task_type, const std::string & db_name, const std::string & coll_name, const bsoncxx::document::view_or_value & filter, const bsoncxx::document::view_or_value & content, const bsoncxx::document::view_or_value & opt, ResultCbFn cb_fn)
{
}

MongoTask::MongoTask(eMongoTask task_type, const std::string & db_name, const std::string & coll_name, const bsoncxx::document::view_or_value & filter, const std::vector<bsoncxx::document::view_or_value>& contents, const bsoncxx::document::view_or_value & opt, ResultCbFn cb_fn)
{
}

MongoTask::~MongoTask()
{
}

void MongoTask::Process()
{
}

void MongoTask::HandleResult()
{
}
