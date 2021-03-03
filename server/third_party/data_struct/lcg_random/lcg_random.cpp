#include "lcg_random.h"

LcgRandom::LcgRandom()
{
}

LcgRandom::LcgRandom(uint64_t seed) : m_seed(seed), m_last_val(seed)
{

}

LcgRandom::LcgRandom(uint64_t seed, uint64_t call_times) : m_seed(seed), m_last_val(seed)
{
	for (int i = 0; i < call_times; ++i)
	{
		Rand();
	}
}

uint64_t LcgRandom::ForceSet(uint64_t seed, uint64_t call_times)
{
	m_seed = seed;
	m_last_val = m_seed;
	m_callTimes = 0;

	for (int i = 0; i < call_times; ++i)
	{
		Rand();
	}

	return m_last_val;
}

uint64_t LcgRandom::Rand()
{
	m_last_val = (LcgRandom::A * m_last_val + LcgRandom::B) & C_Mask;
	++m_callTimes;
	return m_last_val;
}