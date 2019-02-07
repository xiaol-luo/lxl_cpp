#include "test_task.h"
#include <stdio.h>

void TestTask::Process()
{
	printf("TestTask::Process %lld \n", m_id);
}

void TestTask::HandleResult()
{
	printf("TestTask::HandleResult %lld \n", m_id);
}
