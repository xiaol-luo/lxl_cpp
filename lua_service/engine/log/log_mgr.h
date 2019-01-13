#pragma once

#include "module_def/i_module.h"
#include "spdlog/spdlog.h"
#include <set>

enum ELogLevel
{
	ELogLevel_Debug = 0,
	ELogLevel_Info,
	ELogLevel_Warn,
	ELogLevel_Error,
	ELogLevel_Max
};

static spdlog::level::level_enum S_LOGLEVEL_2_SPD_LOGLEVEL[ELogLevel_Max] = {
	spdlog::level::debug,
	spdlog::level::info,
	spdlog::level::warn,
	spdlog::level::err,
};

enum ELoggerType
{
	ELoggerType_Invalid = 0,
	ELoggerType_Stdout,
	ELoggerType_Stderr,
	ELoggerType_Common,
	ELoggerType_Rotating,
	ELoggerType_Daily,
	ELoggerType_Max,
};

enum ELoggerName
{
	ELogger_Debug,
	ELogger_Info,
	ELogger_Warn,
	ELogger_Error,
	ELogger_Stdout,
	ELogger_StdError,
	ELogger_All,
	ELogger_Max,
};

class LogMgr
{
public:
	LogMgr();
	~LogMgr();
	bool Start(ELogLevel log_lvl);
	void Stop();
	void Flush();

public:
	template <typename... Args>
	void Debug(const char* fmt, const Args&... args)
	{
		this->Log(ELogLevel_Debug, fmt, args...);
	}

	template <typename... Args>
	void Info(const char* fmt, const Args&... args)
	{
		this->Log(ELogLevel_Info, fmt, args...);
	}

	template <typename... Args>
	void Warn(const char* fmt, const Args&... args)
	{
		this->Log(ELogLevel_Warn, fmt, args...);
	}

	template <typename... Args>
	void Error(const char* fmt, const Args&... args)
	{
		this->Log(ELogLevel_Error, fmt, args...);
	}

	template <typename... Args>
	void Log(ELogLevel log_level, const char* fmt, const Args&... args)
	{
		if (log_level >= m_min_record_log_level && log_level >= ELogLevel_Debug && log_level < ELogLevel_Max)
		{
			spdlog::level::level_enum spd_log_lvl = S_LOGLEVEL_2_SPD_LOGLEVEL[log_level];
			m_loggers[log_level]->log(spd_log_lvl, fmt, args...);
			if (log_level >= ELogLevel_Error)
			{
				m_loggers[ELogger_StdError]->log(spd_log_lvl, fmt, args...);
			}
			else
			{
				m_loggers[ELogger_Stdout]->log(spd_log_lvl, fmt, args...);
			}
			m_loggers[ELogger_All]->log(spd_log_lvl, fmt, args...);
		}
	}

protected:
	std::shared_ptr<spdlog::logger> m_loggers[ELogger_Max];
	int m_async_queue_size =  1024 * 16;
	ELogLevel m_min_record_log_level = ELogLevel_Debug;
};