#pragma once

#include <stdint.h>
#include <string>

typedef void * (*MallocFn)(size_t);
typedef void (*FreeFn)(void *);
typedef void * (*ReallocFn)(void *, size_t);

class NetBuffer
{
public:
	NetBuffer(uint32_t init_size, uint32_t step_size, MallocFn malloc_fn, FreeFn free_fn, ReallocFn realloc_fn);
	NetBuffer(char *buff, uint32_t buff_size, uint32_t step_size, MallocFn malloc_fn, FreeFn free_fn, ReallocFn realloc_fn);
	~NetBuffer();

	uint32_t LeftSpace();
	uint32_t StepSize();
	uint32_t Capacity();
	char * Ptr();
	uint32_t Pos();
	uint32_t Head();
	char * HeadPtr();
	uint32_t Size();
	bool SetPos(uint32_t new_pos);
	bool SetHead(uint32_t new_head);
	bool AppendBuff(char *buff, uint32_t len);
	bool AppendBuff(const char *buff, uint32_t len);
	bool CheckExpend(uint32_t need_capacity);

	template <typename T>
	bool Append(T t)
	{
		char *p = (char *)(&t);
		uint32_t len = sizeof(T);
		return AppendBuff(p, len);
	}
	uint32_t PopBuff(uint32_t pop_len, char **pop_head);
	bool ResetHead(char *help_buff, uint32_t help_buff_len); // buff和buff+head之间的内容丢弃，buff+head和buff+pos之间的内容移动到buff和buff+pos-head
	bool ResetHead();
	   
private:
	uint32_t m_init_size = 0;
	uint32_t m_step_size = 0;
	char *m_buff = nullptr;
	uint32_t m_head = 0;
	uint32_t m_capacity = 0; // 容量
	uint32_t m_pos = 0; // 可写入的位置
	MallocFn m_malloc_fn = nullptr;
	FreeFn m_free_fn = nullptr;
	ReallocFn m_realloc_fn = nullptr;
};

template<> 
inline bool NetBuffer::Append<std::string>(std::string data)
{
	return AppendBuff((char *)data.data(), data.size());
}
