#pragma once

#include <stdint.h>
#include <functional>

typedef uint64_t TimerID;
using TimerCallback = std::function<void(void)>;

const int64_t MS_PER_SEC = 1000;
const int64_t EXECUTE_UNLIMIT_TIMES = -1;
const TimerID INVALID_TIMER_ID = 0;
