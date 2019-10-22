
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using Utopia;
using XLua;

namespace Lua
{
    public partial class LuaHelp
    {
        public static ulong TimerAdd(LuaFunction luaFn, float delaySec, int callTimes, float callSpanSec)
        {
            ulong tid = 0;
            if (null != luaFn && null != App.ins)
            {
                System.Action cb = () => {
                    luaFn.Call();
                };
                tid = App.ins.timer.Add(cb, delaySec, callTimes, callSpanSec);
            }
            return tid;
        }

        public static void TimerRemove(ulong id)
        {
            if (null != App.ins)
            {
                App.ins.timer.Remove(id);
            }
        }

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

        public static string ScriptRootDir()
        {
#if UNITY_EDITOR
            string luaRootDir = Path.Combine(Path.Combine(UnityEngine.Application.dataPath, ".."), "LuaScript");
            return luaRootDir;
#else
            UnityEngine.Debug.Assert(false);
            return "";
#endif
        }

        public static string[] ScriptSearchDirs()
        {
#if UNITY_EDITOR
            string scriptRootDir = ScriptRootDir();
            List<string> rets = new List<string>();
            foreach(string item in App.ins.root.lua_search_paths)
            {
                string searchDir = string.Format("{0}/{1}", scriptRootDir, item).Replace('\\', '/');
                rets.Add(searchDir);
            }
            return rets.ToArray();
#else
            UnityEngine.Debug.Assert(false);
            return null;
#endif
        }
        public static bool IsFile(string filePath)
        {
#if UNITY_EDITOR
            bool ret = File.Exists(filePath);
            return ret;
#else
            UnityEngine.Debug.Assert(false);
            return null;
#endif
        }
    }
}