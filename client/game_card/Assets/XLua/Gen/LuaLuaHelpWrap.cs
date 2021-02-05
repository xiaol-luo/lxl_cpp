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
    public class LuaLuaHelpWrap 
    {
        public static void __Register(RealStatePtr L)
        {
			ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
			System.Type type = typeof(Lua.LuaHelp);
			Utils.BeginObjectRegister(type, L, translator, 0, 0, 0, 0);
			
			
			
			
			
			
			Utils.EndObjectRegister(type, L, translator, null, null,
			    null, null, null);

		    Utils.BeginClassRegister(type, L, __CreateInstance, 12, 0, 0);
			Utils.RegisterFunc(L, Utils.CLS_IDX, "SetImageSprite", _m_SetImageSprite_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "InstantiateGameObject", _m_InstantiateGameObject_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "IsNull", _m_IsNull_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "TimerAdd", _m_TimerAdd_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "TimerRemove", _m_TimerRemove_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ReloadScripts", _m_ReloadScripts_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "AddLuaSearchPath", _m_AddLuaSearchPath_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ScriptRootDir", _m_ScriptRootDir_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "ScriptSearchDirs", _m_ScriptSearchDirs_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "IsFile", _m_IsFile_xlua_st_);
            Utils.RegisterFunc(L, Utils.CLS_IDX, "SafeCall", _m_SafeCall_xlua_st_);
            
			
            
			
			
			
			Utils.EndClassRegister(type, L, translator);
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int __CreateInstance(RealStatePtr L)
        {
            
			try {
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
				if(LuaAPI.lua_gettop(L) == 1)
				{
					
					Lua.LuaHelp gen_ret = new Lua.LuaHelp();
					translator.Push(L, gen_ret);
                    
					return 1;
				}
				
			}
			catch(System.Exception gen_e) {
				return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
			}
            return LuaAPI.luaL_error(L, "invalid arguments to Lua.LuaHelp constructor!");
            
        }
        
		
        
		
        
        
        
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SetImageSprite_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.UI.Image _image = (UnityEngine.UI.Image)translator.GetObject(L, 1, typeof(UnityEngine.UI.Image));
                    string _assetPath = LuaAPI.lua_tostring(L, 2);
                    XLua.LuaFunction _onEnd = (XLua.LuaFunction)translator.GetObject(L, 3, typeof(XLua.LuaFunction));
                    bool _isSetSize = LuaAPI.lua_toboolean(L, 4);
                    
                        int gen_ret = Lua.LuaHelp.SetImageSprite( _image, _assetPath, _onEnd, _isSetSize );
                        LuaAPI.xlua_pushinteger(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_InstantiateGameObject_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    UnityEngine.GameObject _go = (UnityEngine.GameObject)translator.GetObject(L, 1, typeof(UnityEngine.GameObject));
                    
                        UnityEngine.GameObject gen_ret = Lua.LuaHelp.InstantiateGameObject( _go );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_IsNull_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    object _obj = translator.GetObject(L, 1, typeof(object));
                    
                        bool gen_ret = Lua.LuaHelp.IsNull( _obj );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_TimerAdd_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    XLua.LuaFunction _luaFn = (XLua.LuaFunction)translator.GetObject(L, 1, typeof(XLua.LuaFunction));
                    float _delaySec = (float)LuaAPI.lua_tonumber(L, 2);
                    int _callTimes = LuaAPI.xlua_tointeger(L, 3);
                    float _callSpanSec = (float)LuaAPI.lua_tonumber(L, 4);
                    
                        ulong gen_ret = Lua.LuaHelp.TimerAdd( _luaFn, _delaySec, _callTimes, _callSpanSec );
                        LuaAPI.lua_pushuint64(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_TimerRemove_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    ulong _id = LuaAPI.lua_touint64(L, 1);
                    
                    Lua.LuaHelp.TimerRemove( _id );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ReloadScripts_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _scriptTable = LuaAPI.lua_tostring(L, 1);
                    
                    Lua.LuaHelp.ReloadScripts( _scriptTable );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_AddLuaSearchPath_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _path = LuaAPI.lua_tostring(L, 1);
                    
                    Lua.LuaHelp.AddLuaSearchPath( _path );
                    
                    
                    
                    return 0;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ScriptRootDir_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    
                        string gen_ret = Lua.LuaHelp.ScriptRootDir(  );
                        LuaAPI.lua_pushstring(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_ScriptSearchDirs_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    
                        System.Collections.Generic.List<string> gen_ret = Lua.LuaHelp.ScriptSearchDirs(  );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_IsFile_xlua_st_(RealStatePtr L)
        {
		    try {
            
            
            
                
                {
                    string _filePath = LuaAPI.lua_tostring(L, 1);
                    
                        bool gen_ret = Lua.LuaHelp.IsFile( _filePath );
                        LuaAPI.lua_pushboolean(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        [MonoPInvokeCallbackAttribute(typeof(LuaCSFunction))]
        static int _m_SafeCall_xlua_st_(RealStatePtr L)
        {
		    try {
            
                ObjectTranslator translator = ObjectTranslatorPool.Instance.Find(L);
            
            
            
                
                {
                    XLua.LuaFunction _luaFn = (XLua.LuaFunction)translator.GetObject(L, 1, typeof(XLua.LuaFunction));
                    object[] _fnParams = translator.GetParams<object>(L, 2);
                    
                        object[] gen_ret = Lua.LuaHelp.SafeCall( _luaFn, _fnParams );
                        translator.Push(L, gen_ret);
                    
                    
                    
                    return 1;
                }
                
            } catch(System.Exception gen_e) {
                return LuaAPI.luaL_error(L, "c# exception:" + gen_e);
            }
            
        }
        
        
        
        
        
        
		
		
		
		
    }
}
