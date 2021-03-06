using System;
using System.Collections.Generic;
using UnityEngine;

namespace Utopia
{
    using TimerId = System.UInt64;

    public class TimerModule : CoreModule
    {
        TimerMgr m_timerMgr;
        public TimerModule(Core _app) : base(_app, EModule.TimerModule)
        {
            
        }
        protected override void OnInit()
        {
            base.OnInit();
            m_timerMgr = new TimerMgr(() => { return UnityEngine.Time.realtimeSinceStartup; });
        }
        
        protected override void OnUpdate()
        {
            m_timerMgr.CheckTrigger();
        }

        protected override ERet OnRelease()
        {
            this.ClearAll();
            return base.OnRelease();
        }

        public TimerProxy CreateTimerProxy()
        {
            TimerProxy ret = new TimerProxy(m_timerMgr);
            return ret;
        }

        public ulong Add(System.Action cb, float delaySec, int callTimes, float callSpanSec)
        {
            return m_timerMgr.Add(cb, delaySec, callTimes, callSpanSec);
        }

        public ulong Delay(System.Action cb, float delaySec=0)
        {
            return m_timerMgr.Delay(cb, delaySec);
        }

        public ulong Firm(System.Action cb, int callTimes, float spanSec)
        {
            return m_timerMgr.Firm(cb, callTimes, spanSec);
        }

        public void Remove(ulong id)
        {
            m_timerMgr.Remove(id);
        }

        public void ReleaseAll()
        {
            m_timerMgr.ClearAll();
        }
    }
}

