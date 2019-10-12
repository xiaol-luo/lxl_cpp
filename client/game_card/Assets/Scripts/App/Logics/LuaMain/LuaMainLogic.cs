
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
            m_lua = m_owner.app.lua;
            m_lua.AddLoader(LuaFileLoader);
            object[] ret = null;
            ret = m_lua.DoString(string.Format("entrance_arg_str = '{0}' ", m_owner.app.root.lua_main_args));
            ret = m_lua.DoString(" require  'prepare_env' ");
            // ret = m_lua.DoString(string.Format(" {0}('{1}') ", m_owner.app.root.lua_main_fn, m_owner.app.root.lua_main_args));

        }

        protected override void OnStart()
        {
            
        }

        protected override void OnRelease()
        {
            
        }

        protected override void OnUpdate()
        {

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


