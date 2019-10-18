
using System.Runtime.InteropServices;
using XLua;

namespace XLua.LuaDLL
{
    public partial class Lua
    {
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void register_3rd_lualibs(System.IntPtr L);


        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_rapidjson(System.IntPtr L);

        [MonoPInvokeCallback(typeof(LuaDLL.lua_CSFunction))]
        public static int LoadRapidJson(System.IntPtr L)
        {
            return luaopen_rapidjson(L);
        }

        public static void RapidJsonAddBuildin(XLua.LuaEnv luaEnv)
        {
            luaEnv.AddBuildin("rapidjson", LuaDLL.Lua.LoadRapidJson);
        }



        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_pb(System.IntPtr L);

        [MonoPInvokeCallback(typeof(LuaDLL.lua_CSFunction))]
        public static int LoadPb(System.IntPtr L)
        {
            return luaopen_pb(L);
        }

        public static void PbAddBuildin(XLua.LuaEnv luaEnv)
        {
            luaEnv.AddBuildin("pb", LuaDLL.Lua.LoadPb);
        }

    }
}