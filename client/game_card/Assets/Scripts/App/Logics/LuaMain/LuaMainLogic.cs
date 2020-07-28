
using System.Collections.Generic;
using System.IO;

namespace Utopia
{
    public class LuaMainLogic : LogicBase
    {
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
                lua_fn.Call();
            }
        }

        protected override void OnUpdate()
        {
            XLua.LuaFunction lua_fn = m_lua.Global.Get<XLua.LuaFunction>("on_native_drive_update");
            if (null != lua_fn)
            {
                lua_fn.Call();
            }
        }

#if UNITY_EDITOR
        byte[] LuaFileLoader(ref string filePath)
        {
            if (string.IsNullOrEmpty(filePath))
                return null;

            byte[] bins = null;

            string luaRootDir = Path.Combine(Path.Combine(UnityEngine.Application.dataPath, ".."), "LuaScript");

            foreach (string subDir in Lua.LuaHelp.ScriptSearchDirs())
            {
                // string absSubDir = Path.Combine(luaRootDir, subDir);
                string realFilePath = filePath.Replace('.', '/').Replace('\\', '/');
                string absLuaFile = subDir.Replace("?", realFilePath);
                if (File.Exists(absLuaFile))
                {
                    filePath = absLuaFile;
                    bins = File.ReadAllBytes(absLuaFile);
                }
            }
            return bins;
        }
#endif

    }
}


