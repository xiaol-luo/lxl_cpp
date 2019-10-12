
namespace Lua
{
    public static class LuaUtil
    {
        public static XLua.LuaEnv NewLuaEnv()
        {
            XLua.LuaEnv env = new XLua.LuaEnv();
            XLua.LuaDLL.Lua.register_3rd_lualibs(env.L);
            XLua.LuaDLL.Lua.RapidJsonAddBuildin(env);
            return env;
        }
    }
}