using System;
using System.Collections.Generic;

namespace Utopia
{
    public class EventCallback<EventKeyType>
    {
        public EventCallback(System.Action<EventKeyType> _cb)
        {
            cb = _cb;
        }
        public void Fire(EventKeyType key)
        {
            cb(key);
        }
        public virtual void Fire(EventKeyType key, object param)
        {
            cb(key);
        }

        public System.Action<EventKeyType> cb;
    }

    public class EventCallback<EventKeyType, T> : EventCallback<EventKeyType>
    {
        public EventCallback(Action<EventKeyType, T> _cb) : base(
            (EventKeyType key) => { _cb(key, default(T)); }
            )
        {
            cb2 = _cb;
        }
        public override void Fire(EventKeyType key, object param) 
        {
            if (param is T)
            {
                cb2(key, (T)param);
            }
            else
            {
                AppLog.Error("EventMgr Fire Error: key {0}, invalid cast param to {1}", key.ToString(), typeof(T).FullName);
            }
        }

        Action<EventKeyType, T> cb2;
    }
}