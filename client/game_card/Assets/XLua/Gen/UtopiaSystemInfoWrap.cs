#if USE_UNI_LUA
using LuaAPI = UniLua.Lua;
using RealStatePtr = UniLua.ILuaState;
using LuaCSFunction = UniLua.CSharpFunctionDelegate;
#else
using LuaAPI = XLua.LuaDLL.Lua;
using RealStatePtr = System.IntPtr;
using LuaCSFunction = XLua.LuaDLL.lua_CSFunction;
#endif

using XLua;
using System.Collections.Generic;


namespace XLua.CSObjectWrap
{
    using Utils = XLua.Utils;
    public class UtopiaSystemInfoWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(Utopia.SystemInfo);
			Utils.BeginObjectRegister(type, L, translator, 0, 0, 0, 0);
			
			
			
			
			
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 6, 2, 0);
			Utils.RegisterFunc(L, Utils.CLS_IDX, "IsUseAB", _m_IsUseAB_xlua_st_);
            
			
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "Platform_Name_Stand_Unknown", Utopia.SystemInfo.Platform_Name_Stand_Unknown);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "Platform_Name_Stand_Alone", Utopia.SystemInfo.Platform_Name_Stand_Alone);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "Platform_Name_Stand_Iphone", Utopia.SystemInfo.Platform_Name_Stand_Iphone);
            Utils.RegisterObject(L, translator, Utils.CLS_IDX, "Platform_Name_Stand_Android", Utopia.SystemInfo.Platform_Name_Stand_Android);
            
			Utils.RegisterFunc(L, Utils.CLS_GETTER_IDX, "IsEditor", _g_get_IsEditor);
            Utils.RegisterFunc(L, Utils.CLS_GETTER_IDX, "PlatformName", _g_get_PlatformName);
            
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            return LuaAPI.luaL_error(L, "Utopia.SystemInfo does not have a constructor!");
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_IsUseAB_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    
                        bool gen_ret = Utopia.SystemInfo.IsUseAB(  );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_IsEditor(RealStatePtr L)
        {
		    try {
            
			    LuaAPI.lua_pushboolean(L, Utopia.SystemInfo.IsEditor);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _g_get_PlatformName(RealStatePtr L)
        {
		    try {
            
			    LuaAPI.lua_pushstring(L, Utopia.SystemInfo.PlatformName);
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            return 1;
        }
        
        
        
		
		
		
		
    }
}
