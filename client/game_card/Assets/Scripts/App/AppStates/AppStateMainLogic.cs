
using System;
using Utopia;

namespace Utopia
{
    public class AppStateMainLogic : AppStateBase
    {
        protected bool m_isFirstEnter = true;
        public AppStateMainLogic(AppStateMgr stateMgr) : base(stateMgr, EAppState.MainLogic)
        {

        }

        public override void Enter(object param)
        {
            if (!m_isFirstEnter)
            {
                m_isFirstEnter = false;
                stateMgr.app.logicMgr.Start();
            }
        }

        public override void Update()
        {
            stateMgr.app.logicMgr.Update();
        }
    }
}

