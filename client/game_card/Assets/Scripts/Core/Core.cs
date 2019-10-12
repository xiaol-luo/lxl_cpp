using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net;
using UnityEngine;

namespace Utopia
{
    public partial class Core
    {
        public CoreMain root { get; protected set; }
        public CoreModule.EStage currStage { get; protected set; }
        const int EModuleCount = (int)CoreModule.EModule.Count;
        CoreModule[] m_modules = new CoreModule[EModuleCount];
        protected AppEventMgr m_eventMgr = null;

        protected Core(CoreMain _root)
        {
            root = _root;
            m_eventMgr = new AppEventMgr();

            m_modules[CoreModule.EModule.TimerModule] = new TimerModule(this);
            m_modules[CoreModule.EModule.NetModule] = new NetModule(this);
            m_modules[CoreModule.EModule.TestModule] = new EmptyTestModule(this);
            // m_modules[CoreModule.EModule.TestModule] = new TestCoreModule(this);
            // m_modules[CoreModule.EModule.TestModule] = new TestMsgNetAgentModule(this);

            currStage = CoreModule.EStage.Free;
            ForeachModule((CoreModule module) => {
                module.Init();
            });
            currStage = CoreModule.EStage.Inited;
        }

        public AppEventSubscriber CreateEventSubcriber()
        {
            return new AppEventSubscriber(m_eventMgr);
        }

        public TimerModule timer
        {
            get
            {
                return m_modules[CoreModule.EModule.TimerModule] as TimerModule;
            }
        }

        public NetModule net
        {
            get
            {
                return m_modules[CoreModule.EModule.NetModule] as NetModule;
            }
        }

        public Coroutine StartCoroutine(IEnumerator ie)
        {
            return root.StartCoroutine(ie);
        }

        public void StopCoroutine(Coroutine co)
        {
            root.StopCoroutine(co);
        }

        public void StopAllCoroutines()
        {
            root.StopAllCoroutines();
        }

        public static Core ins { get { return m_ins; } }
        protected static Core m_ins = null;
        public static void MakeInstance(CoreMain _owner)
        {
            if (null == m_ins)
                m_ins = new Core(_owner);
            else
                AppLog.Error("NewApp is single instance, can only make one instance");
        }
    }
}
