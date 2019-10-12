
using System.Collections.Generic;
using UnityEngine;

namespace Utopia
{
    public class CoreMain : MonoBehaviour
    {
        bool m_fistUpdate = false;

        [SerializeField]
        public List<string> lua_search_paths;
        [SerializeField]
        public string lua_main_args;

        public CoreMain()
        {
            lua_search_paths = new List<string>();
        }

        void Start()
        {
            lua_search_paths.Add("?.lua");
            lua_search_paths.Add("?/init.lua");

            AppLog.Init(new ConsoleLogImpl(), null);
            DontDestroyOnLoad(gameObject);
            Core.MakeInstance(this);
            Core.ins.Awake();
            App.MakeInstance(this);
            App.ins.Awake();
        }

        void FixedUpdate()
        {
            Core.ins.Update();
            if (m_fistUpdate)
            {
                m_fistUpdate = false;
                App.ins.Start();
            }
            App.ins.Update();
        }

        void OnApplicationQuit()
        {
            App.ins.Quit();
            Core.ins.Release();
            AppLog.Release();
        }
    }
}
