#include "net_buffer.h"
#include <stdlib.h>
#include <assert.h>
#include <string.h>

NetBuffer::NetBuffer(uint32_t init_size, uint32_t step_size, MallocFn malloc_fn, FreeFn free_fn, ReallocFn realloc_fn)
{
	m_init_size = init_size; 
	m_step_size = step_size;
	assert(m_step_size > 0);

	// 这三个函数必须配套
	bool fn_match = false;
	if ((nullptr == malloc_fn && nullptr == free_fn && nullptr == realloc_fn) ||
		(nullptr != malloc_fn && nullptr != free_fn && nullptr != realloc_fn))
	{
		fn_match = true;
	}
	assert(fn_match);
	m_malloc_fn = nullptr != malloc_fn ? malloc_fn : malloc;
	m_free_fn = nullptr != free_fn ? free_fn : free;
	m_realloc_fn = nullptr != realloc_fn ? realloc_fn : realloc;
}

NetBuffer::NetBuffer(char * buff, uint32_t buff_size, uint32_t step_size, MallocFn malloc_fn, FreeFn free_fn, ReallocFn realloc_fn)
{
	m_buff = buff;
	m_capacity = buff_size;
	m_init_size = buff_size;
	m_step_size = step_size;
	assert(m_buff);
	assert(m_capacity > 0);
	assert(m_step_size > 0);
	// 这三个函数必须配套
	bool fn_match = false;
	if ((nullptr == malloc_fn && nullptr == free_fn && nullptr == realloc_fn) ||
		(nullptr != malloc_fn && nullptr != free_fn && nullptr != realloc_fn))
	{
		fn_match = true;
	}
	assert(fn_match);
	m_malloc_fn = nullptr != malloc_fn ? malloc_fn : malloc;
	m_free_fn = nullptr != free_fn ? free_fn : free;
	m_realloc_fn = nullptr != realloc_fn ? realloc_fn : realloc;
}

NetBuffer::~NetBuffer()
{
	m_free_fn(m_buff); m_buff = nullptr;
}

bool NetBuffer::SetPos(uint32_t new_pos)
{
	if (!this->CheckExpend(new_pos))
		return false;
	m_pos = new_pos;
	if (m_head > m_pos)
	{
		m_head = m_pos;
	}
	return true;
}

bool NetBuffer::SetHead(uint32_t new_head)
{
	if (!this->CheckExpend(new_head))
		return false;
	m_head = new_head;
	if (m_head > m_pos)
	{
		m_pos = m_head;
	}
	return true;
}

bool NetBuffer::AppendBuff(char * buff, uint32_t len)
{
	return this->AppendBuff((const char *)buff, len);
}

bool NetBuffer::AppendBuff(const char * buff, uint32_t len)
{
	if (len <= 0)
		return true;
	if (nullptr == buff)
		return false;
	if (!this->CheckExpend(m_pos + len))
		return false;
	memcpy(this->Ptr(), buff, len);
	m_pos += len;
	return true;
}

uint32_t NetBuffer::PopBuff(uint32_t pop_len, char ** pop_head)
{
	if (nullptr != pop_head)
	{
		*pop_head = m_buff + m_head;
	}
	uint32_t consume_len = pop_len;
	if (m_head + pop_len > m_pos)
	{
		consume_len = m_pos - m_head;
	}
	m_head += consume_len;
	return consume_len;
}

bool NetBuffer::ResetHead(char *help_buff, uint32_t help_buff_len)
{
	bool ret = false;
	uint32_t size = this->Size();
	if (size <= 0)
	{
		ret = true;
		m_head = 0;
		m_pos = 0;
	}
	else if (help_buff_len >= size)
	{
		ret = true;
		memcpy(help_buff, m_buff + m_head, size);
		memcpy(m_buff, help_buff, size);
		m_head = 0;
		m_pos = size;
	}
	return ret;
}

bool NetBuffer::ResetHead()
{
	bool ret = false;
	uint32_t size = this->Size();
	if (size <= 0)
	{
		ret = this->ResetHead(nullptr, 0);
	}
	else
	{
		char *help_buff = (char *)m_malloc_fn(size);
		ret = this->ResetHead(help_buff, size);
		m_free_fn(help_buff); help_buff = nullptr;
	}
	return ret;
}

bool NetBuffer::CheckExpend(uint32_t need_capacity)
{
	if (need_capacity > m_capacity)
	{
		if (nullptr == m_buff)
		{
			m_buff = (char *)m_malloc_fn(m_init_size);
			if (nullptr != m_buff)
				m_capacity = m_init_size;
		}		
		if (need_capacity > m_capacity)
		{
			assert(m_step_size > 0);
			uint32_t new_capacity = m_capacity;
			while (need_capacity > new_capacity)
			{
				new_capacity += m_step_size;
			}
			m_buff = (char *)m_realloc_fn(m_buff, new_capacity);
			if (nullptr != m_buff)
				m_capacity = new_capacity;
			
		}
	}
	return nullptr != m_buff;
}

uint32_t NetBuffer::LeftSpace() { return m_capacity - m_pos; }
uint32_t NetBuffer::StepSize() { return m_step_size; }
uint32_t NetBuffer::Capacity() { return m_capacity; }
char * NetBuffer::Ptr() { return m_buff + m_pos; }
uint32_t NetBuffer::Pos() { return m_pos; }
uint32_t NetBuffer::Head() { return m_head; }
char * NetBuffer::HeadPtr() { return m_buff + m_head; }
uint32_t NetBuffer::Size() { return m_pos - m_head; }
