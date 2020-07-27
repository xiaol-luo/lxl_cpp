using System;
using System.Collections.Generic;

namespace Utopia
{
    public class EventId<EventKeyType>
    {
        public EventKeyType key;
        public ulong idx = 0;
        public WeakReference mgr;
        public void Release()
        {
            if (this.IsValid() && null != mgr && mgr.IsAlive)
            {
                EventMgr<EventKeyType> refMgr = mgr.Target as EventMgr<EventKeyType>;
                if (null != refMgr)
                {
                    refMgr.Cancel(this);
                    idx = 0;
                }
            }
        }

        public bool IsValid()
        {
            return idx > 0;
        }
    }
}