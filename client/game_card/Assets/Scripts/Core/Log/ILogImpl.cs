
namespace Utopia
{
    public enum LogLevel
    {
        Debug,
        Info,
        Waring,
        Error,
        Exception,
        Assert,
    }

    public interface ILogImpl
    {
        bool Init(object param);
        void DoLog(LogLevel lvl, string format, params object[] args);
        void Release();
    }
}