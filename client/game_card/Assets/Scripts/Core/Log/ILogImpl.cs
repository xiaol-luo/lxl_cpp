
namespace Utopia
{
    public enum LogLevel
    {
        Debug,
        Info,
        Warning,
        Error,
        Exception,
        Assert,
    }

    public interface ILogImpl
    {
        bool Init(object param);
        void DoLog(LogLevel lvl, string content);
        void Release();
    }
}