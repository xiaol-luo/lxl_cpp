using UnityEngine;
using XLua;
using System.Collections.Generic;
using System;

namespace Lua
{
    public static class CsharpCallLuaConfig
    {
        [CSharpCallLua]
        public static List<Type> items = new List<Type>()
        {
            typeof(System.Action),
            typeof(UnityEngine.Events.UnityEvent),
            typeof(UnityEngine.Events.UnityAction),
            typeof(CL_ILuaUIComponent),
        };
    }
}