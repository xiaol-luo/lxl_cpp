using System;
using System.Collections.Generic;

namespace Utopia
{
    public class EventMgr
    {
        Dictionary<string, EventCallbackMgr > m_eventCbMgrs = new Dictionary<string, EventCallbackMgr >();

        public EventId Bind(string eventKey, System.Action cb)
        {
            EventCallbackBase ecb = new EventCallback(cb);
            EventId ret = this.DoBind(eventKey, ecb);
            return ret;
        }
        public EventId Bind<T0>(string eventKey, System.Action<T0> cb)
        {
            EventCallbackBase ecb = new EventCallback<T0>(cb); ;
            EventId ret = this.DoBind(eventKey, ecb);
            return ret;
        }
        public EventId Bind<T0, T1>(string eventKey, System.Action<T0, T1> cb)
        {
            EventCallbackBase ecb = new EventCallback<T0, T1>(cb); ;
            EventId ret = this.DoBind(eventKey, ecb);
            return ret;
        }
        public EventId Bind<T0, T1, T2>(string eventKey, System.Action<T0, T1, T2> cb)
        {
            EventCallbackBase ecb = new EventCallback<T0, T1, T2>(cb); ;
            EventId ret = this.DoBind(eventKey, ecb);
            return ret;
        }
        public EventId Bind<T0, T1, T2, T3>(string eventKey, System.Action<T0, T1, T2, T3> cb)
        {
            EventCallbackBase ecb = new EventCallback<T0, T1, T2, T3>(cb); ;
            EventId ret = this.DoBind(eventKey, ecb);
            return ret;
        }

        protected EventId DoBind(string eventKey, EventCallbackBase ecb)
        {
            EventCallbackMgr cbMgr = null;
            if (!m_eventCbMgrs.TryGetValue(eventKey, out cbMgr))
            {
                cbMgr = new EventCallbackMgr(eventKey);
                m_eventCbMgrs.Add(eventKey, cbMgr);
            }
            ulong eid = cbMgr.AddCallback(ecb);
            EventId ret = new EventId();
            ret.key = eventKey;
            ret.idx = eid;
            ret.mgr = new WeakReference(this);
            return ret;
        }

        public void Cancel(EventId eventId)
        {
            EventCallbackMgr cbMgr = null;
            if (m_eventCbMgrs.TryGetValue(eventId.key, out cbMgr))
            {
                cbMgr.RemoveCallback(eventId.idx);
            }
        }

        public void ClearAll()
        {
            m_eventCbMgrs.Clear();
        }

        public void Fire(string eventKey, params object[] param)
        {
            EventCallbackMgr cbMgr = null;
            if (m_eventCbMgrs.TryGetValue(eventKey, out cbMgr))
            {
                cbMgr.FireCallbacks(param);
            }
        }

        public EventProxy CreateEventProxy()
        {
            return new EventProxy(this);
        }
    }
}