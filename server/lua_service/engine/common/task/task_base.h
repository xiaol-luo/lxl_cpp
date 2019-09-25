#pragma once

class AsyncTaskMgr;

class TaskBase 
{
public:
	TaskBase() {}
	virtual ~TaskBase() {}
	virtual void Process() = 0;
	virtual void HandleResult() = 0;
};
