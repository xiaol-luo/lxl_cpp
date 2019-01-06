#pragma once

#include <string>
#include <functional>
#include "network/network_def.h"

namespace Net
{
	enum ENetTaskType
	{
		ENetTask_Connect,
		ENetTask_Listen,
		ENetTaskType_Max,
	};

	enum ENetTaskState
	{
		ENetTask_Ready,
		ENetTask_Process,
		ENetTask_Done,
		ENetTaskState_Max,
	};

	struct NetTaskResult
	{
		ENetTaskType task_type = ENetTaskType_Max;
		int err_num = 0;
		std::string err_msg;
		long long id = 0;
		int fd = -1;
	};

	class NetTask
	{
	public:
		NetTask(ENetTaskType task_type, int64_t id);
		virtual ~NetTask();
		virtual void Process() = 0;
		ENetTaskType TaskType() { return m_task_type; }
		ENetTaskState TaskState() { return m_task_state; }
		int64_t Id() { return m_id; }
		const NetTaskResult & GetResult() { return m_result; }

	protected:
		ENetTaskType m_task_type = ENetTaskType_Max;
		ENetTaskState m_task_state = ENetTask_Ready;
		int64_t m_id = 0;
		NetTaskResult m_result;
	};

	class NetTaskConnect : public NetTask
	{
	public:
		NetTaskConnect(int64_t id, std::string ip, uint16_t port, void *opt);
		virtual ~NetTaskConnect();
		virtual void Process();

	protected:
		std::string m_ip;
		uint16_t m_port = 0;
		void *m_opt = nullptr;
	};

	class NetTaskListen : public NetTask
	{
	public:
		NetTaskListen(int64_t id, std::string ip, uint16_t port, void *opt);
		virtual ~NetTaskListen();
		virtual void Process();

	protected:
		std::string m_ip;
		uint16_t m_port = 0;
		void *m_opt = nullptr;
	};
}