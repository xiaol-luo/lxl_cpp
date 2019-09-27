
namespace Utopia
{
    public class ConsoleLogImpl : ILogImpl
    {
        public bool Init(object param)
        {
            return true;
        }

        public void Release()
        {

        }

        public void DoLog(LogLevel lvl, string format, params object[] args)
        {
            switch (lvl)
            {
                case LogLevel.Debug:
                case LogLevel.Info:
                    {
                        UnityEngine.Debug.LogFormat(format, args);
                    }
                    break;
                case LogLevel.Waring:
                    {
                        UnityEngine.Debug.LogWarningFormat(format, args);
                    }
                    break;
                case LogLevel.Error:
                    {
                        UnityEngine.Debug.LogErrorFormat(format, args);
                    }
                    break;
                case LogLevel.Assert:
                    {
                        UnityEngine.Debug.LogAssertionFormat(format, args);
                    }
                    break;
                case LogLevel.Exception:
                    {
                        UnityEngine.Debug.LogErrorFormat(format, args);
                    }
                    break;
            }
        }
    }
}