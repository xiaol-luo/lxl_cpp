using System;
using System.Collections.Generic;
using UnityEngine;

namespace Utopia
{
    public class TestMsgNetAgentModule : CoreModule
    {
        bool m_firstUpdate = true;
        MsgNetAgent m_msgNetAgent = null;
        TestMsgNetAgentHandler m_msgHandler = null;

        TimerMgr m_timerMgr;
        public TestMsgNetAgentModule(Core _app) : base(_app, EModule.TestModule)
        {
            AppLog.Debug("CoreTestModule new");
        }
        protected override void OnInit()
        {
            base.OnInit();
            AppLog.Debug("CoreTestModule OnInit");
            m_msgNetAgent = new MsgNetAgent();
            m_msgHandler = new TestMsgNetAgentHandler();
            m_msgHandler.m_owner = this;
            m_msgNetAgent.SetHandler(m_msgHandler);
        }
        
        protected override void OnUpdate()
        {
            base.OnUpdate();
            // AppLog.Debug("CoreTestModule OnUpdate");

            if (m_firstUpdate)
            {
                m_firstUpdate = false;
                m_msgNetAgent.Connect("127.0.0.1", 2379);
            }
        }
    }
}

