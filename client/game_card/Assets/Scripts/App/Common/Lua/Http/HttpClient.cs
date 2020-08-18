using UnityEngine;
using UnityEditor;
using Utopia;
using System;
using System.Collections.Generic;

namespace Lua
{
    public static class HttpClient
    {
        public static void Cancel(long operaId)
        {
            if (null == App.ins)
                return;
            App.ins.http.Cancel(operaId);
        }
        public static long Get(string url, XLua.LuaFunction cbFn, XLua.LuaTable headsMap = null, int timeoutSec = 30)
        {
            if (null == App.ins)
                return 0;

            return App.ins.http.Get(url, GenHttpReqWrapCbFn(cbFn), LuaTableToDict(headsMap), timeoutSec);
        }

        public static Action<string/*error*/, byte[]/*bodyContent*/, Dictionary<string, string>/*heads*/> GenHttpReqWrapCbFn(XLua.LuaFunction luaCbFn)
        {
            if (null == luaCbFn)
                return null;

            Action<string, byte[], Dictionary<string, string> > ret = (string error, byte[] rspBody, Dictionary<string, string> headsMap) => {
                luaCbFn.Call(error, rspBody, headsMap);
            };
            return ret;
        }

        public static Dictionary<string, string> LuaTableToDict(XLua.LuaTable tb)
        {
            Dictionary<string, string> ret = new Dictionary<string, string>();
            return ret;
        }
    }
}