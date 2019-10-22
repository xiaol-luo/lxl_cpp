using UnityEngine;
using XLua;
using System.Collections.Generic;
using System;

namespace Lua
{
    public static class LuaCallCSharpConfig
    {
        [LuaCallCSharp]
        public static List<Type> items = new List<Type>()
        {
            typeof(Lua.LuaHelp),
            typeof(Lua.LuaResLoaderProxy),
            typeof(Utopia.ResourceObserver),
            typeof(Utopia.ResourceScene),
            typeof(Utopia.GameNet),
            typeof(Utopia.AppLog),
            typeof(Utopia.LogLevel),
        };
    }
}
