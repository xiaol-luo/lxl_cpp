
using System.Collections.Generic;
using UnityEngine;

namespace Utopia
{
    public class CoreMain : MonoBehaviour
    {
        public List<string> lua_search_paths;
        [SerializeField]
        public string lua_main_args;

        void Awake()
        {
            AppLog.Init(new ConsoleLogImpl(), null);
            DontDestroyOnLoad(gameObject);
            Core.MakeInstance(this);

            lua_search_paths = new List<string>();
            // Lua.LuaHelp.AddLuaSearchPath("?.lua");
            // Lua.LuaHelp.AddLuaSearchPath("?/init.lua");
            Lua.LuaHelp.AddLuaSearchPath("LuaScript/?.lua");
            // Lua.LuaHelp.AddLuaSearchPath("LuaScript/?/init.lua");

            Core.ins.Awake();
            App.MakeInstance(this);

            App.ins.Awake();
        }

        void Start()
        {
            App.ins.Start();
        }

        void FixedUpdate()
        {
            App.ins.FixedUpdate();
        }

        public void Update()
        {
            Core.ins.Update();
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
