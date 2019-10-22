using UnityEngine;
using XLua;
using System.Collections.Generic;
using System;

namespace Lua
{
    public static class CsharpCallLuaConfig
    {
        [LuaCallCSharp]
        public static List<Type> items = new List<Type>()
        {

        };
    }
}