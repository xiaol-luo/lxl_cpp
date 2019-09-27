using System.Collections.Generic;

namespace Utopia
{
    public class EventSubscriber<EventKeyType>
    {
        HashSet<EventId<EventKeyType>> m_eventIdSet = new HashSet<EventId<EventKeyType>>();
        System.WeakReference m_mgr = null;

        public EventSubscriber(EventMgr<EventKeyType> mgr)
        {
            m_mgr = new System.WeakReference(mgr);
        }

        public void ClearAll()
        {
            if (m_mgr.IsAlive)
            {
                EventMgr<EventKeyType> mgr = m_mgr.Target as EventMgr<EventKeyType>;
                foreach (var eventId in m_eventIdSet)
                {
                    mgr.Remove(eventId);
                }
                m_eventIdSet.Clear();
            }
        }

        public void Remove(EventId<EventKeyType> eventId)
        {
            if (m_mgr.IsAlive)
            {
                EventMgr<EventKeyType> mgr = m_mgr.Target as EventMgr<EventKeyType>;
                if (m_eventIdSet.Contains(eventId))
                {
                    m_eventIdSet.Remove(eventId);
                    mgr.Remove(eventId);
                }
            }
        }

        public EventId<EventKeyType> Subscribe(EventKeyType eventKey, System.Action<EventKeyType> cb)
        {
            if (m_mgr.IsAlive)
            {
                EventMgr<EventKeyType> mgr = m_mgr.Target as EventMgr<EventKeyType>;
                EventId<EventKeyType> ret = mgr.Subscribe(eventKey, cb);
                if (ret.IsValid())
                {
                    m_eventIdSet.Add(ret);
                }
                return ret;
            }
            return new EventId<EventKeyType>();
        }
        public EventId<EventKeyType> Subscribe<T>(EventKeyType eventKey, System.Action<EventKeyType, T> cb)
        {
            if (m_mgr.IsAlive)
            {
                EventMgr<EventKeyType> mgr = m_mgr.Target as EventMgr<EventKeyType>;
                EventId<EventKeyType> ret = mgr.Subscribe(eventKey, cb);
                if (ret.IsValid())
                {
                    m_eventIdSet.Add(ret);
                }
                return ret;
            }
            return new EventId<EventKeyType>();
        }
    }
}
