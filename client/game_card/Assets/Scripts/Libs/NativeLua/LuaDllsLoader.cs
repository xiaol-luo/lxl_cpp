
using System.Runtime.InteropServices;
using XLua;

namespace XLua.LuaDLL
{
    public partial class Lua
    {
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern void register_3rd_lualibs(System.IntPtr L);

        // Begin rapidjson
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
        // End rapidjson


        // Begin PB
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
        // End PB

        // Begin sproto
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_sproto_core(System.IntPtr L);

        [MonoPInvokeCallback(typeof(LuaDLL.lua_CSFunction))]
        public static int LoadSprotoCore(System.IntPtr L)
        {
            return luaopen_sproto_core(L);
        }

        public static void SprotoAddBuildin(XLua.LuaEnv luaEnv)
        {
            luaEnv.AddBuildin("sproto.core", LuaDLL.Lua.LoadSprotoCore);
        }
        // End sproto

        // Begin lpeg
        [DllImport(LUADLL, CallingConvention = CallingConvention.Cdecl)]
        public static extern int luaopen_lpeg(System.IntPtr L);

        [MonoPInvokeCallback(typeof(LuaDLL.lua_CSFunction))]
        public static int LoadLpeg(System.IntPtr L)
        {
            return luaopen_lpeg(L);
        }

        public static void LpegAddBuildin(XLua.LuaEnv luaEnv)
        {
            luaEnv.AddBuildin("lpeg", LuaDLL.Lua.LoadLpeg);
        }
        // End lpeg
    }
}