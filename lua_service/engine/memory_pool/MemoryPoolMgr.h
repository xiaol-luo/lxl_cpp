#pragma once

#include <vector>
#include <mutex>

class MemoryPool;

class MemoryPoolMgr
{
public:
	MemoryPoolMgr(std::vector<size_t> block_sizes, size_t memory_page_size, size_t expect_working_block_set_num, size_t min_block_num_per_block_set);
	~MemoryPoolMgr();

	const static uint32_t BLOCK_SIZE_DESCRIPT_LEN = sizeof(size_t);
	void * Malloc(size_t malloc_size);
	void * Realloc(void *ptr, size_t new_size);
	void Free(void *ptr);

private:
	struct MemoryPoolData
	{
		MemoryPoolData(MemoryPool *_memory_pool) : memory_pool(_memory_pool) {}
		std::mutex mtx;
		MemoryPool *memory_pool = nullptr;
	};

	std::vector<MemoryPoolData *> m_memory_pools;
	size_t m_max_block_size = 0;
	MemoryPoolData **m_memory_pool_fast_idx = nullptr;

	const static size_t BLOCK_SIZE_MULTI_BASE = 8; // block must be times of 8

	static size_t CalPoolIndex(size_t malloc_size);
};
