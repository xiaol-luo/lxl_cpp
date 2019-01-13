#include "net_buffer.h"
#include <stdlib.h>
#include <assert.h>
#include <string.h>

NetBuffer::NetBuffer(uint32_t init_size, uint32_t step_size)
{
	m_init_size = init_size; 
	m_step_size = step_size;
	assert(m_step_size > 0);
}

NetBuffer::NetBuffer(char * buff, uint32_t buff_size, uint32_t step_size)
{
	m_buff = buff;
	m_capacity = buff_size;
	m_init_size = buff_size;
	m_step_size = step_size;
	assert(m_buff);
	assert(m_capacity > 0);
	assert(m_step_size > 0);
}

NetBuffer::~NetBuffer()
{
	free(m_buff); m_buff = nullptr;
}

void NetBuffer::SetPos(uint32_t new_pos)
{
	this->CheckExpend(new_pos);
	m_pos = new_pos;
	if (m_head > m_pos)
	{
		m_head = m_pos;
	}
}

void NetBuffer::SetHead(uint32_t new_head)
{
	this->CheckExpend(new_head);
	m_head = new_head;
	if (m_head > m_pos)
	{
		m_pos = m_head;
	}
}

void NetBuffer::AppendBuff(char * buff, uint32_t len)
{
	this->CheckExpend(m_pos + len);
	memcpy(this->Ptr(), buff, len);
	m_pos += len;
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

bool NetBuffer::ResetHead(char *help_buff, uint32_t buff_len)
{
	uint32_t size = this->Size();
	bool ret = false;
	if (buff_len >= size)
	{
		ret = true;
		memcpy(help_buff, m_buff + m_head, size);
		memcpy(m_buff, help_buff, size);
		m_head = 0;
		m_pos = size;
	}
	return ret;
}

void NetBuffer::CheckExpend(uint32_t need_capacity)
{
	if (need_capacity > m_capacity)
	{
		if (nullptr == m_buff)
		{
			m_buff = (char *)malloc(m_init_size);
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
			m_buff = (char *)realloc(m_buff, new_capacity);
			m_capacity = new_capacity;
		}
	}
}

uint32_t NetBuffer::LeftSpace() { return m_capacity - m_pos; }
uint32_t NetBuffer::StepSize() { return m_step_size; }
uint32_t NetBuffer::Capacity() { return m_capacity; }
char * NetBuffer::Ptr() { return m_buff + m_pos; }
uint32_t NetBuffer::Pos() { return m_pos; }
uint32_t NetBuffer::Head() { return m_head; }
char * NetBuffer::HeadPtr() { return m_buff + m_head; }
uint32_t NetBuffer::Size() { return m_pos - m_head; }
