#pragma once

#include "task_base.h"
#include <stdint.h>

class TestTask : public TaskBase
{
public:
	TestTask() {}
	virtual ~TestTask() {}

	void SetId(int64_t id) { m_id = id; }
	virtual void Process();
	virtual void HandleResult();

private:
	int64_t m_id;
};
