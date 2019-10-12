
// using AppEventMgr = Utopia.EventMgr<string>;
// using AppEventSubscriber = Utopia.EventSubscriber<string>;

namespace Utopia
{
    public class AppEventMgr : Utopia.EventMgr<string>
    {
    }

    public class AppEventSubscriber : Utopia.EventSubscriber<string>
    {
        public AppEventSubscriber(EventMgr<string> mgr) : base(mgr)
        {
        }
    }
}