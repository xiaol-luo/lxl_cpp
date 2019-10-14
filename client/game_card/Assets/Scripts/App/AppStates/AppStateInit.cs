
using System;
using Utopia;

namespace Utopia
{
    public class AppStateInit : AppStateBase
    {
        bool m_isInited = false;

        public AppStateInit(AppStateMgr stateMgr) : base(stateMgr, EAppState.Init)
        {

        }

        public override void Enter(object param)
        {
            if (m_isInited)
                return;

            m_isInited = true;
            App app = stateMgr.app;
            app.logicMgr.Init();
        }
    }
}

