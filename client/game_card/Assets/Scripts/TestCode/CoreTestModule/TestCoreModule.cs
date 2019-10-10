using System;
using System.Collections.Generic;
using UnityEngine;

namespace Utopia
{
    using TimerId = System.UInt64;

    public class TestCoreModule : CoreModule
    {
        TimerMgr m_timerMgr;
        XLua.LuaEnv m_luaEnv;
        public TestCoreModule(Core _app) : base(_app, EModule.TestModule)
        {
            AppLog.Debug("CoreTestModule new");
        }
        protected override void OnInit()
        {
            base.OnInit(); 
            AppLog.Debug("CoreTestModule OnInit");

            m_luaEnv = Lua.LuaUtil.NewLuaEnv();

        }

        protected override void OnUpdate()
        {
            base.OnUpdate();
            AppLog.Debug("CoreTestModule OnUpdate");

            // m_luaEnv.DoString("CS.UnityEngine.Debug.Log('hello world')"); 
            
            m_luaEnv.DoString(@"
print('xxxxxxxxxxxxxxxxxxxxxxxxxxxx')
json = require('rapidjson')
t = json.decode('{'a':123}')
print(t.a)
                ");
            int a = 0;
            a++;
        }
    }
}

