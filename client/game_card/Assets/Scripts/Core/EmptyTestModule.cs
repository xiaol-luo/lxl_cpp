using System;
using System.Collections.Generic;
using UnityEngine;

namespace Utopia
{
    using TimerId = System.UInt64;

    public class EmptyTestModule : CoreModule
    {
        TimerMgr m_timerMgr;
        public EmptyTestModule(Core _app) : base(_app, EModule.TestModule)
        {
            
        }
        protected override void OnInit()
        {
            base.OnInit();
        }
        
        protected override void OnUpdate()
        {
            base.OnUpdate();
        }
    }
}

