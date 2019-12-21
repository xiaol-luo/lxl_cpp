using UnityEngine;
using XLua;
using System.Collections.Generic;
using System;

namespace Lua
{
    public static class LuaCallCSharpConfig
    {
        [LuaCallCSharp]
        public static List<Type> unity_classes = new List<Type>()
        {
            typeof(GameObject),
            typeof(Transform),
            typeof(UnityEngine.MonoBehaviour),
            typeof(UnityEngine.Component),
            typeof(UnityEngine.UI.Text),
            typeof(Color),
        };

        [LuaCallCSharp]
        public static List<Type> utopia_classes = new List<Type>()
        {
            typeof(Lua.LuaHelp),

            typeof(Lua.LuaResLoaderProxy),
            typeof(Utopia.ResourceObserver),
            typeof(Utopia.ResourceScene),

            typeof(Utopia.AppLog),
            typeof(Utopia.LogLevel),

            typeof(Utopia.GameNet),
            typeof(Utopia.LuaGameNet),

            typeof(Utopia.UIRoot),

            typeof(Utopia.ResourceObserver),

            typeof(LuaUIComponent),
        };
    }
}
