using System;
using System.Collections.Generic;
using UnityEngine;

namespace Utopia
{
    using TimerId = System.UInt64;

    public class EmptyTestModule : CoreModule
    {
        TimerMgr m_timerMgr;
        public EmptyTestModule(Core _app) : base(_app, EModule.TestModule)
        {
            
        }
        protected override void OnInit()
        {
            base.OnInit();
        }

        protected override ERet OnAwake()
        {
            //ResourceLoader.ins.AsyncLoadScene("Assets/Res/Scene/OtherTest/OtherTest.unity", true, (ResourceScene.LoadResult ret, string path) =>
            //{
            //    AppLog.Debug("ResourceLoader.ins.AsyncLoadScene {0}, {1}", path, ret);
            //});

            //this.core.http.Get("https://g100.gdl.netease.com/game_config_list.json", (string errorStr, byte[] rspContent, Dictionary<string, string> rspHeads) => {
            //    int a = 0;
            //    ++a;
            //}, new Dictionary<string, string>(), 40);
            return base.OnAwake();
        }

        protected override void OnUpdate()
        {
            base.OnUpdate();
        }
    }
}

