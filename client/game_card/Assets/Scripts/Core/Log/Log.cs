
namespace Utopia
{
    public class Log
    {
        protected ILogImpl m_logImpl = null;
        protected object m_param;
        
        public bool Init(ILogImpl logImpl, object param)
        {
            m_logImpl = logImpl;
            m_param = param;
            return m_logImpl.Init(param);
        }

        public void Release()
        {
            if (null != m_logImpl)
            {
                m_logImpl.Release();
                m_logImpl = null;
            }
        }

        LogLevel m_logLvl = LogLevel.Debug;
        public void SetLogLvl(LogLevel lvl)
        {
            m_logLvl = lvl;
        }
        public LogLevel logLvl { get { return m_logLvl; } }

        public void Debug(string format, params object[] args)
        {
            this.DoLog(LogLevel.Debug, format, args);
        }
        public void Info(string format, params object[] args)
        {
            this.DoLog(LogLevel.Info, format, args);
        }

        public void Warning(string format, params object[] args)
        {
            this.DoLog(LogLevel.Waring, format, args);
        }

        public void Error(string format, params object[] args)
        {
            this.DoLog(LogLevel.Error, format, args);
        }

        public void Exception(System.Exception e)
        {
            this.DoLog(LogLevel.Exception, "{0}", e.ToString());
        }

        public void Assert(bool isTrue, string format, params object[] args)
        {
            if (!isTrue)
            {
                this.DoLog(LogLevel.Assert, format, args);
            }
        }

        public void DoLog(LogLevel lvl, string format, params object[] args)
        {
            if (lvl < m_logLvl)
                return;

            m_logImpl.DoLog(lvl, string.Format(format, args));
        }

        public void DoLogContent(LogLevel lvl, string content)
        {
            if (lvl < m_logLvl)
                return;

            m_logImpl.DoLog(lvl, content);
        }
    }
}

