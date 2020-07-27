using System;
using System.Collections.Generic;

namespace Utopia
{
    public class EventCallbackMgr<EventKeyType>
    {
        public EventCallbackMgr(EventKeyType eventKey)
        {
            m_eventKey = eventKey;
        }

        EventKeyType m_eventKey;
        public const ulong Invalid_Id = 0;

        protected ulong lastId = 0;
        public Dictionary<ulong, EventCallback<EventKeyType> > cbs = new Dictionary<ulong, EventCallback<EventKeyType> >();

        public ulong AddCallback(EventCallback<EventKeyType> cb)
        {
            if (null == cb)
                return Invalid_Id;
            cbs.Add(++lastId, cb);
            return lastId;
        }
        public void RemoveCallback(ulong id)
        {
            cbs.Remove(id);
        }

        public void FireCallbacks()
        {
            List<EventCallback<EventKeyType> > tmp = new List<EventCallback<EventKeyType> >(cbs.Values);
            foreach (EventCallback<EventKeyType> cb in tmp)
            {
                cb.Fire(m_eventKey);
            }
        }
        public void FireCallbacks(object param)
        {
            List<EventCallback<EventKeyType>> tmp = new List<EventCallback<EventKeyType>>(cbs.Values);
            foreach (EventCallback<EventKeyType> cb in tmp)
            {
                cb.Fire(m_eventKey, param);
            }
        }
    }
}