using System.Runtime.CompilerServices;
using System.Collections.Generic;

namespace Utopia
{
    public class EventBinder
    {
        ConditionalWeakTable<EventMgr, EventProxy> m_mgrToProxy = new ConditionalWeakTable<EventMgr, EventProxy>();
        Dictionary<EventId, System.WeakReference> m_idToMgr = new Dictionary<EventId, System.WeakReference>();

        public EventBinder()
        {

        }

        public void CancelAll()
        {
            HashSet<EventMgr> eventMgrSet = new HashSet<EventMgr>();
            foreach (System.WeakReference wkEventMgr in m_idToMgr.Values)
            {
                if (wkEventMgr.IsAlive)
                {
                    EventMgr eventMgr = wkEventMgr.Target as EventMgr;
                    eventMgrSet.Add(eventMgr);
                }
            }
            m_idToMgr.Clear();

            var eventMgrSetIt = eventMgrSet.GetEnumerator();
            eventMgrSetIt.MoveNext();
            while (null != eventMgrSetIt.Current)
            {
                EventMgr eventMgr = eventMgrSetIt.Current;
                EventProxy eventProxy = null;
                if (m_mgrToProxy.TryGetValue(eventMgr, out eventProxy))
                {
                    m_mgrToProxy.Remove(eventMgr);
                    eventProxy.CancelAll();
                }
                eventMgrSetIt.MoveNext();
            }

            // 这里通过m_idToMgr的key release掉事件监听， 然后创建一个新的m_mgrToProxy更简单
        }

        public void Cancel(EventId eventId)
        {
            System.WeakReference wkEventMgr = null;
            if (m_idToMgr.TryGetValue(eventId, out wkEventMgr))
            {
                m_idToMgr.Remove(eventId);
                if (wkEventMgr.IsAlive)
                {
                    EventMgr eventMgr = wkEventMgr.Target as EventMgr;
                    EventProxy eventProxy = null;
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

        public EventId Bind(EventMgr eventMgr, string eventKey, System.Action cb)
        {
            EventProxy eventProxy = this.GetProxy(eventMgr, true);
            EventId id = eventProxy.Bind(eventKey, cb);
            if (id.IsValid())
                m_idToMgr.Add(id, new System.WeakReference(eventMgr));
            return id;
        }
        public EventId Bind<T>(EventMgr eventMgr, string eventKey, System.Action<T> cb)
        {
            EventProxy eventProxy = this.GetProxy(eventMgr, true);
            EventId  id = eventProxy.Bind(eventKey, cb);
            if (id.IsValid())
                m_idToMgr.Add(id, new System.WeakReference(eventMgr));
            return id;
        }
        public EventId Bind<T0, T1>(EventMgr eventMgr, string eventKey, System.Action<T0, T1> cb)
        {
            EventProxy eventProxy = this.GetProxy(eventMgr, true);
            EventId id = eventProxy.Bind(eventKey, cb);
            if (id.IsValid())
                m_idToMgr.Add(id, new System.WeakReference(eventMgr));
            return id;
        }
        public EventId Bind<T0, T1, T2>(EventMgr eventMgr, string eventKey, System.Action<T0, T1, T2> cb)
        {
            EventProxy eventProxy = this.GetProxy(eventMgr, true);
            EventId id = eventProxy.Bind(eventKey, cb);
            if (id.IsValid())
                m_idToMgr.Add(id, new System.WeakReference(eventMgr));
            return id;
        }
        public EventId Bind<T0, T1, T2, T3>(EventMgr eventMgr, string eventKey, System.Action<T0, T1, T2, T3> cb)
        {
            EventProxy eventProxy = this.GetProxy(eventMgr, true);
            EventId id = eventProxy.Bind(eventKey, cb);
            m_idToMgr.Add(id, new System.WeakReference(eventMgr));
            return id;
        }

        protected EventProxy GetProxy(EventMgr eventMgr, bool is_create)
        {
            EventProxy eventProxy = null;
            if (!m_mgrToProxy.TryGetValue(eventMgr, out eventProxy))
            {
                if (is_create)
                {
                    eventProxy = eventMgr.CreateEventProxy();
                    m_mgrToProxy.Add(eventMgr, eventProxy);
                }
            }
            return eventProxy;
        }
    }
}
