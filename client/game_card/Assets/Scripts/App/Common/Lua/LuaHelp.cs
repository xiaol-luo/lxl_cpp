
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.UI;
using Utopia;
using XLua;
using Utopia.Resource;

namespace Lua
{
    public partial class LuaHelp
    {
        public static int SetImageSprite(Image image, string assetPath, XLua.LuaFunction onEnd, bool isSetSize)
        {
            return ImageRefMonitorMono.Set(image, assetPath, (seq, refMono, i, s) => {
                if (seq == refMono.setOperaSeq)
                {
                    i.sprite = s;
                    if (isSetSize)
                    {
                        i.SetNativeSize();
                    }
                }
                if (null != onEnd)
                {
                    SafeCall(onEnd, seq, refMono, i, s);
                }
            });
        }

        public static GameObject InstantiateGameObject(GameObject go)
        {
            GameObject ret = null;
            if (null != go)
            {
                ret = GameObject.Instantiate(go);
                GameObjectUtils.MakeTravelAwake(ret);
            }
            return ret;
        }

        public static bool IsNull(object obj)
        {
            return null == obj;
        }

        public static ulong TimerAdd(LuaFunction luaFn, float delaySec, int callTimes, float callSpanSec)
        {
            ulong tid = 0;
            if (null != luaFn && null != App.ins)
            {
                System.Action cb = () => {
                    SafeCall(luaFn);
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
            SafeCall(loadFiles, scriptTable);
        }

        public static void AddLuaSearchPath(string path)
        {
            bool needAdd = true;
            string realPath = Path.Combine(ScriptRootDir(), path).Replace('\\', '/');
#if USE_AB
            realPath += ".bytes";
#endif
            foreach (string item in Core.ins.root.lua_search_paths)
            {
                if (realPath == item.Replace('\\', '/'))
                {
                    needAdd = false;
                    break;
                }
            }
            if (needAdd)
            {
                Core.ins.root.lua_search_paths.Add(realPath);
            }
        }

        public static string ScriptRootDir()
        {
#if !USE_AB
            string ret = Path.Combine(UnityEngine.Application.dataPath, "..");
#else
            string ret = "Assets/Res/lua_script";
#endif
            return ret;
        }

        public static List<string> ScriptSearchDirs()
        {
            return Core.ins.root.lua_search_paths;
        }
        public static bool IsFile(string filePath)
        {
#if !USE_AB
            bool ret = File.Exists(filePath);
            return ret;
#else
            UnityEngine.Debug.Assert(false);
            return false;
#endif
        }

        public static object[] SafeCall(LuaFunction luaFn, params object[] fnParams)
        {
            if (null != luaFn)
            {
                try
                {
                    return luaFn.Call(fnParams);
                }
                catch (System.Exception ex)
                {
                    AppLog.Error("SafeCall Error: {0}", ex.ToString());
                }
            }
            return null;
        }
    }
}