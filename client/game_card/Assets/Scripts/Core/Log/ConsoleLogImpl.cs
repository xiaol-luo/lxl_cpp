
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

        public void DoLog(LogLevel lvl, string content)
        {
            switch (lvl)
            {
                case LogLevel.Debug:
                case LogLevel.Info:
                    {
                        UnityEngine.Debug.Log(content);
                    }
                    break;
                case LogLevel.Warning:
                    {
                        UnityEngine.Debug.LogWarning(content);
                    }
                    break;
                case LogLevel.Error:
                    {
                        UnityEngine.Debug.LogError(content);
                    }
                    break;
                case LogLevel.Assert:
                    {
                        UnityEngine.Debug.LogAssertion(content);
                    }
                    break;
                case LogLevel.Exception:
                    {
                        UnityEngine.Debug.LogError(content);
                    }
                    break;
            }
        }
    }
}