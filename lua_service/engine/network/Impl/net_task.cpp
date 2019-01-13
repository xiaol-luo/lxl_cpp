#include "net_task.h"
#include <fcntl.h>

#ifndef WIN32
#include <unistd.h>
#endif // !WIN32

namespace Net
{
	NetTask::NetTask(ENetTaskType task_type, int64_t id)
	{
		m_task_type = task_type;
		m_id = id;
		m_result.id = m_id;
		m_result.task_type = m_task_type;
	}

	NetTask::~NetTask()
	{

	}

	NetTaskConnect::NetTaskConnect(int64_t id, std::string ip, uint16_t port, void *opt)
		: NetTask(ENetTask_Connect, id), m_ip(ip), m_port(port), m_opt(opt)
	{
	}

	NetTaskConnect::~NetTaskConnect()
	{

	}

	NetTaskListen::NetTaskListen(int64_t id, std::string ip, uint16_t port, void *opt)
		: NetTask(ENetTask_Listen, id), m_ip(ip), m_port(port), m_opt(opt)
	{

	}

	NetTaskListen::~NetTaskListen()
	{

	}

#ifdef WIN32

#include <winsock2.h>
#pragma comment(lib, "ws2_32.lib")

	void NetTaskConnect::Process()
	{
		if (ENetTask_Ready != m_task_state)
			return;

		m_task_state = ENetTask_Process;
		SOCKET sock = -1;
		do
		{
			sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
			if (INVALID_SOCKET == sock)
			{
				m_result.err_num = GetLastError();
				m_result.err_msg = "create socket fail";
				sock = -1;
				break;
			}

			struct sockaddr_in listen_addr;
			listen_addr.sin_family = AF_INET;
			listen_addr.sin_addr.S_un.S_addr = inet_addr(m_ip.c_str());
			listen_addr.sin_port = htons(m_port);
			memset(listen_addr.sin_zero, 0x00, 8);
			if (0 != connect(sock, (struct sockaddr *)&listen_addr, sizeof(listen_addr)))
			{
				m_result.err_num = GetLastError();
				m_result.err_msg = "connect socket fail";
				break;
			}

			Net::u_long ret = 0;
			ioctlsocket(sock, FIONBIO, &ret);
			m_result.fd = sock;

		} while (false);
		if (0 != m_result.err_num)
		{
			if (sock >= 0)
				closesocket(sock);
		}
		m_task_state = ENetTask_Done;
	}

	void NetTaskListen::Process()
	{
		if (ENetTask_Ready != m_task_state)
			return;

		m_task_state = ENetTask_Process;
		SOCKET sock = -1;
		do
		{
			sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
			if (INVALID_SOCKET == sock)
			{
				m_result.err_num = GetLastError();
				m_result.err_msg = "create socket fail";
				sock = -1;
				break;
			}

			struct sockaddr_in listen_addr;
			listen_addr.sin_family = AF_INET;
			listen_addr.sin_addr.S_un.S_addr = inet_addr(m_ip.c_str());
			listen_addr.sin_port = htons(m_port);
			memset(listen_addr.sin_zero, 0x00, 8);
			if (0 != bind(sock, (struct sockaddr *)&listen_addr, sizeof(listen_addr)))
			{
				m_result.err_num = GetLastError();
				m_result.err_msg = "bind socket fail";
				break;
			}
			if (0 != listen(sock, 64))
			{
				m_result.err_num = GetLastError();
				m_result.err_msg = "listen socket fail";
				break;
			}
			Net::u_long ret = 0;
			ioctlsocket(sock, FIONBIO, &ret);
			m_result.fd = sock;

		} while (false);
		if (0 != m_result.err_num)
		{
			if (sock >= 0)
				closesocket(sock);
		}
		m_task_state = ENetTask_Done;
	}

#else

#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <errno.h>

	typedef int SOCKET;

	void NetTaskConnect::Process()
	{
		if (ENetTask_Ready != m_task_state)
			return;

		m_task_state = ENetTask_Process;
		SOCKET sock = -1;
		do
		{
			sock = socket(AF_INET, SOCK_STREAM, 0);
			if (-1 == sock)
			{
				m_result.err_num = errno;
				m_result.err_msg = "create socket fail";
				sock = -1;
				break;
			}

			struct sockaddr_in listen_addr;
			listen_addr.sin_family = AF_INET;
			listen_addr.sin_addr.s_addr = inet_addr(m_ip.c_str());
			listen_addr.sin_port = htons(m_port);
			if (0 != connect(sock, (struct sockaddr *)&listen_addr, sizeof(listen_addr)))
			{
				m_result.err_num = errno;
				m_result.err_msg = "connect socket fail";
				break;
			}

			int flag = fcntl(sock, F_GETFL, 0) | O_NONBLOCK;
			fcntl(sock, F_SETFL, flag);
			m_result.fd = sock;

		} while (false);
		if (0 != m_result.err_num)
		{
			if (sock >= 0)
				close(sock);
		}
		m_task_state = ENetTask_Done;
	}

	void NetTaskListen::Process()
	{
		if (ENetTask_Ready != m_task_state)
			return;

		m_task_state = ENetTask_Process;
		SOCKET sock = -1;
		do
		{
			sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
			if (-1 == sock)
			{
				m_result.err_num = errno;
				m_result.err_msg = "create socket fail";
				sock = -1;
				break;
			}

			struct sockaddr_in listen_addr;
			listen_addr.sin_family = AF_INET;
			listen_addr.sin_addr.s_addr = inet_addr(m_ip.c_str());
			listen_addr.sin_port = htons(m_port);
			if (0 != bind(sock, (struct sockaddr *)&listen_addr, sizeof(listen_addr)))
			{
				m_result.err_num = errno;
				m_result.err_msg = "bind socket fail";
				break;
			}
			if (0 != listen(sock, 64))
			{
				m_result.err_num = errno;
				m_result.err_msg = "listen socket fail";
				break;
			}
			int flag = fcntl(sock, F_GETFL, 0) | O_NONBLOCK;
			fcntl(sock, F_SETFL, flag);
			m_result.fd = sock;

		} while (false);
		if (0 != m_result.err_num)
		{
			if (sock >= 0)
				close(sock);
		}
		m_task_state = ENetTask_Done;
	}

#endif
}