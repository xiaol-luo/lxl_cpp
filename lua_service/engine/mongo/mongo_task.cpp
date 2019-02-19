#include "mongo_task.h"


MongoTask::MongoTask(eMongoTask task_type, bsoncxx::document::view_or_value filter, bsoncxx::document::view_or_value content, bsoncxx::document::view_or_value opt, ResultCbFn cb_fn)
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
