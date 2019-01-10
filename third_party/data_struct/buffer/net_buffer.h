#pragma once

#include <stdint.h>

class NetBuffer
{
public:
	NetBuffer(uint32_t init_size, uint32_t step_size);
	NetBuffer(char *buff, uint32_t buff_size, uint32_t step_size);
	~NetBuffer();

	char * Ptr() { return m_buff + m_pos; }
	uint32_t Pos() { return m_pos; }
	uint32_t Head() { return m_head; }
	uint32_t Size() { return m_pos - m_head; }
	void SetPos(uint32_t new_pos);
	void SetHead(uint32_t new_head);
	void AppendBuff(char *buff, uint32_t len);
	template <typename T>
	void Append(T t)
	{
		char *p = (char *)(&t);
		uint32_t len = sizeof(T);
		WriteBuff(p, len);
	}

	uint32_t PopBuff(uint32_t pop_len, char **pop_head);
	bool ResetHead(char *help_buff, uint32_t buff_len); // buff和buff+head之间的内容丢弃，buff+head和buff+pos之间的内容移动到buff和buff+pos-head
	   
private:
	uint32_t m_init_size = 0;
	uint32_t m_step_size = 0;
	char *m_buff = nullptr;
	uint32_t m_head = 0;
	uint32_t m_capacity = 0; // 容量
	uint32_t m_pos = 0; // 可写入的位置

	void CheckExpend(uint32_t need_capacity);
};
