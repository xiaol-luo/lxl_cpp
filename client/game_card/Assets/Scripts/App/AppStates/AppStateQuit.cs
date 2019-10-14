
using System;
using Utopia;

namespace Utopia
{
    public class AppStateQuit : AppStateBase
    {
        bool m_isFirstEnter = true;

        public AppStateQuit(AppStateMgr stateMgr) : base(stateMgr, EAppState.Quit)
        {

        }

        public override void Enter(object param)
        {
            /*
            Core.instance.eventMgr.Fire(AppEvent.GameToQuit);
            App.instance.panelMgr.Destory();
            App.instance.logicMgr.Release();
            Core.instance.Release();
            */

            if (m_isFirstEnter)
            {
                m_isFirstEnter = false;
                stateMgr.app.logicMgr.Release();
            }
        }
    }
}

