
using System.Collections.Generic;
using System.IO;

namespace Utopia
{
    public class TestLogic : LogicBase
    {
        // XLua.LuaEnv m_lua = null;
        List<string> m_lua_search_paths = new List<string>();

        public override EAppLogicName GetModuleName()
        {
            return EAppLogicName.TestLogic;
        }
        protected override void OnInit()
        {
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
    }
}


