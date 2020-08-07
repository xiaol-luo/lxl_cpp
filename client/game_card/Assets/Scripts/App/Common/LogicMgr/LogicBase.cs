using UnityEngine;
using UnityEditor;

namespace Utopia
{
    public abstract class LogicBase : Utopia.EventMgr
    {
        protected TimerProxy m_timerProxy = Core.ins.timer.CreateTimerProxy();
        protected LogicMgr m_logicMgr = null;

        public LogicBase()
        {
        }

        public void SetLogicMgr(LogicMgr owner)
        {
            UnityEngine.Debug.Assert(null == m_logicMgr);
            UnityEngine.Debug.Assert(null != owner);
            m_logicMgr = owner;
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
            this.ClearAll();
            m_timerProxy.ClearAll();
        }
    }
}
