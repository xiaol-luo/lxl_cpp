#pragma once
#include <stdint.h>

class LcgRandom
{
public:
	LcgRandom();
	LcgRandom(uint64_t seed);
	LcgRandom(uint64_t seed, uint64_t call_times);

	uint64_t ForceSet(uint64_t seed, uint64_t call_times);
	uint64_t Rand();

	uint64_t GetSeed() { return m_seed; }
	uint64_t GetCallTimes() { return m_callTimes; }
	uint64_t GetLastVal() { return m_last_val; }

public:
	// next(x) = (a * x + b) mod c
	const uint64_t A = 25214903917;
	const uint64_t B = 11;
	const uint64_t C = 1LL << 48;
	const uint64_t C_Mask = C - 1;
protected:
	uint64_t m_last_val = 0;
	uint64_t m_seed = 0;
	uint64_t m_callTimes = 0;
};