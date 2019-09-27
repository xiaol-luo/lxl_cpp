namespace Utopia
{
    // AppLog的生命周期要全包围Core.ins
    public static class AppLog
    {
        private static Log s_log = null;
        public static bool Init(ILogImpl logImpl, object param)
        {
            if (null != s_log)
                return false;

            s_log = new Log();
            return s_log.Init(logImpl, param);
        }

        public static void SetLogLvl(LogLevel lvl)
        {
            s_log.SetLogLvl(lvl);
        }

        public static void Release()
        {
            if (null != s_log)
            {
                s_log.Release();
                s_log = null;
            }
        }

        public static void Debug(string format, params object[] args)
        {
            s_log.DoLog(LogLevel.Debug, format, args);
        }
        public static void Info(string format, params object[] args)
        {
            s_log.DoLog(LogLevel.Info, format, args);
        }

        public static void Warning(string format, params object[] args)
        {
            s_log.DoLog(LogLevel.Waring, format, args);
        }

        public static void Error(string format, params object[] args)
        {
            s_log.DoLog(LogLevel.Error, format, args);
        }

        public static void Exception(System.Exception e)
        {
            s_log.DoLog(LogLevel.Exception, "{0}", e.ToString());
        }

        public static void Assert(bool isTrue, string format, params object[] args)
        {
            if (!isTrue)
            {
                s_log.DoLog(LogLevel.Assert, format, args);
            }
        }

        public static void DoLog(LogLevel lvl, string format, params object[] args)
        {
            s_log.DoLog(lvl, format, args);
        }
    }
}