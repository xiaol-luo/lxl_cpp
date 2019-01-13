#include "log_mgr.h"

struct LoggerConfig
{
	LoggerConfig(ELoggerType _logger_type, std::string _name, std::string _file_name,
		size_t _rorating_max_size, size_t _rorating_max_file, 
		int _daily_hour, int _daily_min) 
		: logger_type(_logger_type), name(_name), file_name(_file_name),
		rorating_max_size(_rorating_max_size), rorating_max_file(_rorating_max_file),
		daily_hour(_daily_hour), daily_min(_daily_min) {}

	ELoggerType logger_type = ELoggerType_Max;
	std::string name;
	std::string file_name;
	size_t rorating_max_size = 100;
	size_t rorating_max_file = 100;
	int daily_hour = 0;
	int daily_min = 0;
};

static const size_t DEFAULT_RORATING_MAX_SIZE = 100;
static const size_t DEFAULT_RORATING_MAX_FILE = 100;
static const int DEFAULT_DAILY_HOUR = 23;
static const int DEFAULT_DAILY_MIN = 45;

static LoggerConfig S_LOG_CONFIGS[/*ELogger_Max*/] = {
	LoggerConfig(ELoggerType_Common, "debug", "debug.log", DEFAULT_RORATING_MAX_SIZE, DEFAULT_RORATING_MAX_FILE, DEFAULT_DAILY_HOUR, DEFAULT_DAILY_MIN),
	LoggerConfig(ELoggerType_Common, "info", "info.log", DEFAULT_RORATING_MAX_SIZE, DEFAULT_RORATING_MAX_FILE, DEFAULT_DAILY_HOUR, DEFAULT_DAILY_MIN),
	LoggerConfig(ELoggerType_Common, "warn", "warn.log", DEFAULT_RORATING_MAX_SIZE, DEFAULT_RORATING_MAX_FILE, DEFAULT_DAILY_HOUR, DEFAULT_DAILY_MIN),
	LoggerConfig(ELoggerType_Common, "error", "error.log", DEFAULT_RORATING_MAX_SIZE, DEFAULT_RORATING_MAX_FILE, DEFAULT_DAILY_HOUR, DEFAULT_DAILY_MIN),
	LoggerConfig(ELoggerType_Stdout, "stdout", "stdout.log", DEFAULT_RORATING_MAX_SIZE, DEFAULT_RORATING_MAX_FILE, DEFAULT_DAILY_HOUR, DEFAULT_DAILY_MIN),
	LoggerConfig(ELoggerType_Stderr, "stderr", "stderr.log", DEFAULT_RORATING_MAX_SIZE, DEFAULT_RORATING_MAX_FILE, DEFAULT_DAILY_HOUR, DEFAULT_DAILY_MIN),
	LoggerConfig(ELoggerType_Common, "all", "all.log", DEFAULT_RORATING_MAX_SIZE, DEFAULT_RORATING_MAX_FILE, DEFAULT_DAILY_HOUR, DEFAULT_DAILY_MIN),
};
static_assert(7 == ELogger_Max, "ELogger_Max is change, please check S_LOG_CONFIGS[]");

LogMgr::LogMgr()
{

}

LogMgr::~LogMgr()
{

}

bool LogMgr::Start(ELogLevel log_lvl)
{
	m_min_record_log_level = log_lvl;
	bool ret = true;
	do 
	{
		spdlog::set_async_mode(m_async_queue_size);
		spdlog::set_level(spdlog::level::debug);

		for (int i = 0; i < ELogger_Max; ++i)
		{
			std::shared_ptr<spdlog::logger> logger = nullptr;
			LoggerConfig *cfg = &S_LOG_CONFIGS[i];
			switch (cfg->logger_type)
			{
				case ELoggerType_Stderr:
				{
					logger = spdlog::stderr_color_mt(cfg->name);
				}
				break;
				case ELoggerType_Stdout:
				{
					logger = spdlog::stdout_color_mt(cfg->name);
				}
				break;
				case ELoggerType_Common:
				{
					logger = spdlog::basic_logger_mt(cfg->name, cfg->file_name, false);
				}
				break;
				case ELoggerType_Rotating:
				{
					logger = spdlog::rotating_logger_mt(cfg->name, cfg->file_name, cfg->rorating_max_size, cfg->rorating_max_file);
				}
				break;
				case ELoggerType_Daily:
				{
					logger = spdlog::daily_logger_mt(cfg->name, cfg->file_name, cfg->daily_hour, cfg->daily_min);
				}
				break;
			}
			if (nullptr == logger)
			{
				ret = false;
				break;
			}
			m_loggers[i] = logger;
		}
	} while (false);

	return ret;
}

void LogMgr::Stop()
{
	for (int i = 0; i < ELogger_Max; ++i)
	{
		if (nullptr != m_loggers[i])
		{
			m_loggers[i]->flush();
			m_loggers[i] = nullptr;
		}
	}
	spdlog::drop_all();
}

void LogMgr::Flush()
{
	for (int i = 0; i < ELogger_Max; ++i)
	{
		if (nullptr != m_loggers[i])
		{
			m_loggers[i]->flush();
		}
	}
}
