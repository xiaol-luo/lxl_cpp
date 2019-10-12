using UnityEngine;
using UnityEditor;

namespace Utopia
{
    public abstract class LogicBase
    {
        protected AppEventMgr m_eventMgr = new AppEventMgr();
        protected TimerProxy m_timerProxy = Core.ins.timer.CreateTimerProxy();
        protected LogicMgr m_owner = null;

        public LogicBase()
        {
        }

        public void SetOwner(LogicMgr owner)
        {
            UnityEngine.Debug.Assert(null == m_owner);
            UnityEngine.Debug.Assert(null != owner);
            m_owner = owner;
        }

        public abstract EAppLogicName GetModuleName();
        protected abstract void OnInit();
        protected abstract void OnStart();
        protected abstract void OnUpdate();
        protected abstract void OnRelease();

        public void Init()
        {
            this.OnInit();
        }

        public void Start()
        {
            this.OnStart();
        }

        public void Update()
        {
            this.OnUpdate();
        }

        public void Release()
        {
            this.OnRelease();
            m_eventMgr.ClearAll();
            m_timerProxy.ClearAll();
        }
        public AppEventSubscriber CreateEventSubcriber()
        {
            return new AppEventSubscriber(m_eventMgr);
        }
    }
}
