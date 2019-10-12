
using System.IO;
using UnityEngine;
using Utopia;
using XLua;

namespace Lua
{
    [LuaCallCSharp]
    public partial class LuaHelp
    {
        public static void ReloadScripts(string scriptTable)
        {
            LuaFunction loadFiles = App.ins.lua.Global.Get<LuaFunction>("reload_files");
            loadFiles.Call(scriptTable);
        }

        public static void AddLuaSearchPath(string path)
        {
            bool needAdd = true;
            string tmpPath = path.Replace('\\', '/');
            foreach (string item in App.ins.root.lua_search_paths)
            {
                if (tmpPath == item.Replace('\\', '/'))
                {
                    needAdd = false;
                    break;
                }
            }
            if (needAdd)
            {
                App.ins.root.lua_search_paths.Add(path);
            }
        }
    }
}