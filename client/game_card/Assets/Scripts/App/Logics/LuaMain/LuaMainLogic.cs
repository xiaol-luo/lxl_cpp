
using System.Collections.Generic;
using System.IO;
using UnityEngine;

namespace Utopia
{
    public class LuaMainLogic : LogicBase
    {
#if USE_AB
        ResourceLoaderProxy m_resLoaderProxy = ResourceLoaderProxy.Create();
#endif
        XLua.LuaEnv m_lua = null;

        public override EAppLogicName GetModuleName()
        {
            return EAppLogicName.LuaMain;
        }
        protected override void OnInit()
        {
            m_lua = m_logicMgr.app.lua;
        }

        protected override void OnStart()
        {
            m_lua.AddLoader(LuaFileLoader);
            object[] ret = null;
            ret = m_lua.DoString(string.Format("entrance_arg_str = '{0}' ", m_logicMgr.app.core.lua_main_args));
            ret = m_lua.DoString(" require  'prepare_env' ");
            // ret = m_lua.DoString(string.Format(" {0}('{1}') ", m_owner.app.root.lua_main_fn, m_owner.app.root.lua_main_args));
        }

        protected override void OnRelease()
        {
            XLua.LuaFunction lua_fn = m_lua.Global.Get<XLua.LuaFunction>("release_lua_logics");
            if (null != lua_fn)
            {
                Lua.LuaHelp.SafeCall(lua_fn);
            }
        }

        protected override void OnUpdate()
        {
            XLua.LuaFunction lua_fn = m_lua.Global.Get<XLua.LuaFunction>("on_native_drive_update");
            if (null != lua_fn)
            {
                Lua.LuaHelp.SafeCall(lua_fn);
            }
        }

#if !USE_AB
        byte[] LuaFileLoader(ref string filePath)
        {
            if (string.IsNullOrEmpty(filePath))
                return null;

            byte[] bins = null;

            string luaRootDir = Lua.LuaHelp.ScriptRootDir();
            foreach (string subDir in Lua.LuaHelp.ScriptSearchDirs())
            {
                // string absSubDir = Path.Combine(luaRootDir, subDir);
                string realFilePath = filePath.Replace('.', '/').Replace('\\', '/');
                string absLuaFile = subDir.Replace("?", realFilePath);
                if (File.Exists(absLuaFile))
                {
                    filePath = absLuaFile;
                    bins = File.ReadAllBytes(absLuaFile);
                    break;
                }
            }
            return bins;
        }
#else
        byte[] LuaFileLoader(ref string filePath)
        {
            if (string.IsNullOrEmpty(filePath))
                return null;

            byte[] bins = null;

            foreach (string subDir in Lua.LuaHelp.ScriptSearchDirs())
            {
                string realFilePath = filePath.Replace('.', '/').Replace('\\', '/');
                string absLuaFile = subDir.Replace("?", realFilePath);

                ResourceObserver resOb = m_resLoaderProxy.LoadAsset(absLuaFile);
                if (null != resOb)
                {
                    TextAsset ta = resOb.res as TextAsset;
                    bins = ta.bytes;
                    break;
                }
            }
            return bins;
        }
#endif
    }
}


