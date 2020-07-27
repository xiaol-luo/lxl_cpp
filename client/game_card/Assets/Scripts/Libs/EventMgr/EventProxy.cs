using System.Collections.Generic;

namespace Utopia
{
    public class EventProxy<EventKeyType>
    {
        HashSet<EventId<EventKeyType>> m_eventIdSet = new HashSet<EventId<EventKeyType>>();
        System.WeakReference m_mgr = null;

        public EventProxy(EventMgr<EventKeyType> mgr)
        {
            m_mgr = new System.WeakReference(mgr);
        }

        public void CancelAll()
        {
            if (m_mgr.IsAlive)
            {
                EventMgr<EventKeyType> mgr = m_mgr.Target as EventMgr<EventKeyType>;
                foreach (var eventId in m_eventIdSet)
                {
                    mgr.Cancel(eventId);
                }
                m_eventIdSet.Clear();
            }
            this.CheckAlive();
        }

        public void Cancel(EventId<EventKeyType> eventId)
        {
            if (m_mgr.IsAlive)
            {
                EventMgr<EventKeyType> mgr = m_mgr.Target as EventMgr<EventKeyType>;
                if (m_eventIdSet.Contains(eventId))
                {
                    m_eventIdSet.Remove(eventId);
                    mgr.Cancel(eventId);
                }
            }
            this.CheckAlive();
        }

        public EventId<EventKeyType> Bind(EventKeyType eventKey, System.Action<EventKeyType> cb)
        {
            if (m_mgr.IsAlive)
            {
                EventMgr<EventKeyType> mgr = m_mgr.Target as EventMgr<EventKeyType>;
                EventId<EventKeyType> ret = mgr.Bind(eventKey, cb);
                if (ret.IsValid())
                {
                    m_eventIdSet.Add(ret);
                }
                return ret;
            }
            this.CheckAlive();
            return new EventId<EventKeyType>();
        }
        public EventId<EventKeyType> Bind<T>(EventKeyType eventKey, System.Action<EventKeyType, T> cb)
        {
            if (m_mgr.IsAlive)
            {
                EventMgr<EventKeyType> mgr = m_mgr.Target as EventMgr<EventKeyType>;
                EventId<EventKeyType> ret = mgr.Bind(eventKey, cb);
                if (ret.IsValid())
                {
                    m_eventIdSet.Add(ret);
                }
                return ret;
            }
            this.CheckAlive();
            return new EventId<EventKeyType>();
        }

        protected void CheckAlive()
        {
            if (!m_mgr.IsAlive)
            {
                m_eventIdSet.Clear();
            }
        }

        public int EventIdCount()
        {
            this.CheckAlive();
            return m_eventIdSet.Count;
        }
    }
}
