
using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Net;
using UnityEngine;

namespace Utopia
{
    public class App
    {        
        bool m_isQuited = false;
        public CoreMain root { get; protected set; }
        public Transform uiRoot { get; protected set; }

        public XLua.LuaEnv lua { get; protected set; }
        public TimerModule timer { get { return Core.ins.timer; } }
        public NetModule net { get { return Core.ins.net; } }

        public LogicMgr logicMgr { get; protected set; }

        protected App(CoreMain _mono)
        {
            root = _mono;
            uiRoot = root.transform.Find("UIRoot").transform;
            lua = Lua.LuaUtil.NewLuaEnv();
            logicMgr = new LogicMgr(this);
        }

        public void Awake()
        {
            logicMgr.Init();
        }

        public void Start()
        {
            logicMgr.Start();
        }

        public void Update()
        {
            if (m_isQuited)
                return;

            logicMgr.Update();
        }

        public void Quit()
        {
            if (m_isQuited)
                return;

            m_isQuited = true;
            logicMgr.Release();
        }

        public static App ins { get { return m_ins; } }
        protected static App m_ins = null;
        public static void MakeInstance(CoreMain _owner)
        {
            if (null == m_ins)
            {
                m_ins = new App(_owner);
            }
            else
            {
                Debug.LogError("App is single instance, can only make one instance");
            }
        }
    }
}