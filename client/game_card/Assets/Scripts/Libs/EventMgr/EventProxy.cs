using System.Collections.Generic;

namespace Utopia
{
    public class EventProxy
    {
        HashSet<EventId> m_eventIdSet = new HashSet<EventId>();
        System.WeakReference m_mgr = null;

        public EventProxy(EventMgr mgr)
        {
            m_mgr = new System.WeakReference(mgr);
        }

        public void CancelAll()
        {
            if (m_mgr.IsAlive)
            {
                EventMgr mgr = m_mgr.Target as EventMgr;
                foreach (var eventId in m_eventIdSet)
                {
                    mgr.Cancel(eventId);
                }
                m_eventIdSet.Clear();
            }
            this.CheckAlive();
        }

        public void Cancel(EventId eventId)
        {
            if (m_mgr.IsAlive)
            {
                EventMgr mgr = m_mgr.Target as EventMgr;
                if (m_eventIdSet.Contains(eventId))
                {
                    m_eventIdSet.Remove(eventId);
                    mgr.Cancel(eventId);
                }
            }
            this.CheckAlive();
        }

        public EventId Bind(string eventKey, System.Action cb)
        {
            if (m_mgr.IsAlive)
            {
                EventMgr mgr = m_mgr.Target as EventMgr;
                EventId ret = mgr.Bind(eventKey, cb);
                if (ret.IsValid())
                    m_eventIdSet.Add(ret);
                return ret;
            }
            this.CheckAlive();
            return new EventId();
        }
        public EventId Bind<T>(string eventKey, System.Action<T> cb)
        {
            if (m_mgr.IsAlive)
            {
                EventMgr mgr = m_mgr.Target as EventMgr;
                EventId ret = mgr.Bind(eventKey, cb);
                if (ret.IsValid())
                    m_eventIdSet.Add(ret);
                return ret;
            }
            this.CheckAlive();
            return new EventId();
        }
        public EventId Bind<T0, T1>(string eventKey, System.Action<T0, T1> cb)
        {
            if (m_mgr.IsAlive)
            {
                EventMgr mgr = m_mgr.Target as EventMgr;
                EventId ret = mgr.Bind(eventKey, cb);
                if (ret.IsValid())
                    m_eventIdSet.Add(ret);
                return ret;
            }
            this.CheckAlive();
            return new EventId();
        }
        public EventId Bind<T0, T1, T2>(string eventKey, System.Action<T0, T1, T2> cb)
        {
            if (m_mgr.IsAlive)
            {
                EventMgr mgr = m_mgr.Target as EventMgr;
                EventId ret = mgr.Bind(eventKey, cb);
                if (ret.IsValid())
                    m_eventIdSet.Add(ret);
                return ret;
            }
            this.CheckAlive();
            return new EventId();
        }
        public EventId Bind<T0, T1, T2, T3>(string eventKey, System.Action<T0, T1, T2, T3> cb)
        {
            if (m_mgr.IsAlive)
            {
                EventMgr mgr = m_mgr.Target as EventMgr;
                EventId ret = mgr.Bind(eventKey, cb);
                if (ret.IsValid())
                    m_eventIdSet.Add(ret);
                return ret;
            }
            this.CheckAlive();
            return new EventId();
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
