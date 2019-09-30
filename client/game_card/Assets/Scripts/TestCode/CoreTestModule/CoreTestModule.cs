using System;
using System.Collections.Generic;
using UnityEngine;

namespace Utopia
{
    using TimerId = System.UInt64;

    public class CoreTestModule : CoreModule
    {
        TimerMgr m_timerMgr;
        public CoreTestModule(Core _app) : base(_app, EModule.TestModule)
        {
            AppLog.Debug("CoreTestModule new");
        }
        protected override void OnInit()
        {
            base.OnInit();
            AppLog.Debug("CoreTestModule OnInit");
        }
        
        protected override void OnUpdate()
        {
            base.OnUpdate();
            AppLog.Debug("CoreTestModule OnUpdate");
        }
    }
}

