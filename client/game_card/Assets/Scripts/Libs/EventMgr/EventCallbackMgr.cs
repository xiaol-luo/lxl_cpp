using System;
using System.Collections.Generic;

namespace Utopia
{
    public class EventCallbackMgr
    {
        public EventCallbackMgr(string eventKey)
        {
            m_eventKey = eventKey;
        }

        string m_eventKey;
        public const ulong Invalid_Id = 0;

        protected ulong lastId = 0;
        protected Dictionary<ulong, EventCallbackBase> m_cbs = new Dictionary<ulong, EventCallbackBase>();
        protected HashSet<EventCallbackBase> m_toRemoveCbs = new HashSet<EventCallbackBase>();
        protected int m_fireDeep = 0;
        protected HashSet<ulong> m_toRemoveIds = new HashSet<ulong>();
        

        public ulong AddCallback(EventCallbackBase cb)
        {
            if (null == cb)
                return Invalid_Id;
            m_cbs.Add(++lastId, cb);
            return lastId;
        }
        public void RemoveCallback(ulong id)
        {
            if (m_fireDeep > 0)
            {
                m_toRemoveIds.Add(id);
            }
            else
            {
                m_cbs.Remove(id);
            }
        }

        public void FireCallbacks(params object[] args)
        {
            ++this.m_fireDeep;

            List<EventCallbackBase> tmp = new List<EventCallbackBase>(m_cbs.Values);
            foreach (var kv in m_cbs)
            {
                if (!m_toRemoveIds.Contains(kv.Key))
                {
                    kv.Value.Fire(m_eventKey, args);
                }
                else
                {
                    int a = 0;
                    ++a;
                }
            }
            --this.m_fireDeep;

            if (this.m_fireDeep <= 0 && m_toRemoveIds.Count > 0)
            {
                foreach (ulong id in m_toRemoveIds)
                {
                    m_cbs.Remove(id);
                }
                m_toRemoveIds.Clear();
            }
        }
    }
}