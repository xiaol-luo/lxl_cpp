using System;
using System.Collections.Generic;

namespace Utopia
{
    public class EventId
    {
        public string key;
        public ulong idx = 0;
        public WeakReference mgr;
        public void Release()
        {
            if (this.IsValid() && null != mgr && mgr.IsAlive)
            {
                EventMgr refMgr = mgr.Target as EventMgr;
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