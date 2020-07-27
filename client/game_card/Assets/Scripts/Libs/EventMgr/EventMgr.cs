using System;
using System.Collections.Generic;

namespace Utopia
{
    public class EventMgr<EventKeyType>
    {
        Dictionary<EventKeyType, EventCallbackMgr<EventKeyType> > m_eventCbMgrs = new Dictionary<EventKeyType, EventCallbackMgr<EventKeyType> >();

        public EventId<EventKeyType> Bind(EventKeyType eventKey, System.Action<EventKeyType> cb)
        {
            EventCallback<EventKeyType> ecb = new EventCallback<EventKeyType>(cb);
            EventId<EventKeyType> ret = this.DoBind(eventKey, ecb);
            return ret;
        }
        public EventId<EventKeyType> Bind<T>(EventKeyType eventKey, System.Action<EventKeyType, T > cb)
        {
            EventCallback<EventKeyType> ecb = new EventCallback<EventKeyType, T>(cb); ;
            EventId<EventKeyType> ret = this.DoBind(eventKey, ecb);
            return ret;
        }

        protected EventId<EventKeyType> DoBind(EventKeyType eventKey, EventCallback<EventKeyType> ecb)
        {
            EventCallbackMgr<EventKeyType> cbMgr = null;
            if (!m_eventCbMgrs.TryGetValue(eventKey, out cbMgr))
            {
                cbMgr = new EventCallbackMgr<EventKeyType>(eventKey);
                m_eventCbMgrs.Add(eventKey, cbMgr);
            }
            ulong eid = cbMgr.AddCallback(ecb);
            EventId<EventKeyType> ret = new EventId<EventKeyType>();
            ret.key = eventKey;
            ret.idx = eid;
            ret.mgr = new WeakReference(this);
            return ret;
        }

        public void Cancel(EventId<EventKeyType> eventId)
        {
            EventCallbackMgr<EventKeyType> cbMgr = null;
            if (m_eventCbMgrs.TryGetValue(eventId.key, out cbMgr))
            {
                cbMgr.RemoveCallback(eventId.idx);
            }
        }

        public void ClearAll()
        {
            m_eventCbMgrs.Clear();
        }

        public void Fire(EventKeyType eventKey)
        {
            EventCallbackMgr<EventKeyType> cbMgr = null;
            if (m_eventCbMgrs.TryGetValue(eventKey, out cbMgr))
            {
                cbMgr.FireCallbacks();
            }
        }
        public void Fire(EventKeyType eventKey, object param)
        {
            EventCallbackMgr<EventKeyType> cbMgr = null;
            if (m_eventCbMgrs.TryGetValue(eventKey, out cbMgr))
            {
                cbMgr.FireCallbacks(param);
            }
        }

        public EventProxy<EventKeyType> CreateEventProxy()
        {
            return new EventProxy<EventKeyType>(this);
        }
    }
}