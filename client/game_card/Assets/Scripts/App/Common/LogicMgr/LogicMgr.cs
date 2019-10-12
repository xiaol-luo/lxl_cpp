using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System;

namespace Utopia
{
    public class LogicMgr
    {
        LogicBase[] m_modules = new LogicBase[(int)EAppLogicName.Count];
        Dictionary<Type, LogicBase> m_moduleMap = new Dictionary<Type, LogicBase>();
        public App app { get; protected set; }

        public LogicMgr(App _app)
        {
            app = _app;
            this.AddModuleHelper<LuaMainLogic>();
            this.AddModuleHelper<TestLogic>();
        }

        protected void AddModuleHelper<T>() where T : LogicBase, new()
        {
            T module = new T();
            module.SetOwner(this);
            EAppLogicName moduleName = module.GetModuleName();
            AppLog.Assert(null == m_modules[(int)moduleName], "Repeated Module {0}", moduleName);
            m_modules[(int)moduleName] = module;
            m_moduleMap.Add(typeof(T), module);
        }

        public void Init()
        {
            foreach (LogicBase module in m_modules)
            {
                module.Init();
            }
        }

        public void Start()
        {
            foreach (LogicBase module in m_modules)
            {
                module.Start();
            }
        }

        public void Update()
        {
            foreach (LogicBase module in m_modules)
            {
                module.Update();
            }
        }

        public void Release()
        {
            foreach (LogicBase module in m_modules)
            {
                module.Release();
            }
        }

        public LogicBase GetModule(EAppLogicName moduleName)
        {
            LogicBase ret = m_modules[(int)moduleName];
            return ret;
        }

        public T GetModule<T>() where T : LogicBase
        {
            LogicBase ret = null;
            m_moduleMap.TryGetValue(typeof(T), out ret);
            return ret as T;
        }
    }
}
