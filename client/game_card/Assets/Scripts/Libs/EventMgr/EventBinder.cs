using System.Runtime.CompilerServices;
using System.Collections.Generic;

namespace Utopia
{
    public class EventBinder<EventKeyType>
    {
        ConditionalWeakTable<EventMgr<EventKeyType>, EventProxy<EventKeyType>> m_mgrToProxy = new ConditionalWeakTable<EventMgr<EventKeyType>, EventProxy<EventKeyType>>();
        Dictionary<EventId<EventKeyType>, System.WeakReference> m_idToMgr = new Dictionary<EventId<EventKeyType>, System.WeakReference>();

        public EventBinder()
        {

        }

        public void CancelAll()
        {
            HashSet<EventMgr<EventKeyType>> eventMgrSet = new HashSet<EventMgr<EventKeyType>>();
            foreach (System.WeakReference wkEventMgr in m_idToMgr.Values)
            {
                if (wkEventMgr.IsAlive)
                {
                    EventMgr<EventKeyType> eventMgr = wkEventMgr.Target as EventMgr<EventKeyType>;
                    eventMgrSet.Add(eventMgr);
                }
            }
            m_idToMgr.Clear();

            var eventMgrSetIt = eventMgrSet.GetEnumerator();
            eventMgrSetIt.MoveNext();
            while (null != eventMgrSetIt.Current)
            {
                EventMgr<EventKeyType> eventMgr = eventMgrSetIt.Current;
                EventProxy<EventKeyType> eventProxy = null;
                if (m_mgrToProxy.TryGetValue(eventMgr, out eventProxy))
                {
                    m_mgrToProxy.Remove(eventMgr);
                    eventProxy.CancelAll();
                }
                eventMgrSetIt.MoveNext();
            }

            // 这里通过m_idToMgr的key release掉事件监听， 然后创建一个新的m_mgrToProxy更简单
        }

        public void Cancel(EventId<EventKeyType> eventId)
        {
            System.WeakReference wkEventMgr = null;
            if (m_idToMgr.TryGetValue(eventId, out wkEventMgr))
            {
                m_idToMgr.Remove(eventId);
                if (wkEventMgr.IsAlive)
                {
                    EventMgr<EventKeyType> eventMgr = wkEventMgr.Target as EventMgr<EventKeyType>;
                    EventProxy<EventKeyType> eventProxy = null;
                    if (m_mgrToProxy.TryGetValue(eventMgr, out eventProxy))
                    {
                        eventProxy.Cancel(eventId);
                        if (eventProxy.EventIdCount() <= 0)
                        {
                            m_mgrToProxy.Remove(eventMgr);
                        }
                    }
                }
            }
            // eventId.Release(); // 多次释放不回有问题的
        }

        public EventId<EventKeyType> Bind(EventMgr<EventKeyType> eventMgr, EventKeyType eventKey, System.Action<EventKeyType> cb)
        {
            EventProxy<EventKeyType> eventProxy = null;
            if (!m_mgrToProxy.TryGetValue(eventMgr, out eventProxy))
            {
                eventProxy = eventMgr.CreateEventProxy();
                m_mgrToProxy.Add(eventMgr, eventProxy);
            }
            EventId<EventKeyType> ret = eventProxy.Bind(eventKey, cb);
            m_idToMgr.Add(ret, new System.WeakReference(eventMgr));
            return ret;
        }
        public EventId<EventKeyType> Bind<T>(EventMgr<EventKeyType> eventMgr, EventKeyType eventKey, System.Action<EventKeyType, T> cb)
        {
            EventProxy<EventKeyType> eventProxy = null;
            if (!m_mgrToProxy.TryGetValue(eventMgr, out eventProxy))
            {
                eventProxy = eventMgr.CreateEventProxy();
                m_mgrToProxy.Add(eventMgr, eventProxy);
            }
            EventId<EventKeyType>  ret = eventProxy.Bind(eventKey, cb);
            m_idToMgr.Add(ret, new System.WeakReference(eventMgr));
            return ret;
        }
    }
}
