using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using XLua;

public class LuaUIComponent : MonoBehaviour
{
    Dictionary<Int64, CL_ILuaUIComponent> m_comps = new Dictionary<Int64, CL_ILuaUIComponent>();

    public void Register(LuaTable tb)
    {
        CL_ILuaUIComponent luaUIComp = tb.Cast<CL_ILuaUIComponent>();
        if (null != luaUIComp && !m_comps.ContainsKey(luaUIComp.unique_id))
        {
            m_comps.Add(luaUIComp.unique_id, luaUIComp);
        }
    }

    public void Unregister(LuaTable tb)
    {
        CL_ILuaUIComponent luaUIComp = tb.Cast<CL_ILuaUIComponent>();
        if (null != luaUIComp)
        {
            m_comps.Remove(luaUIComp.unique_id);
        }
    }

    private void OnEnable()
    {
        foreach (CL_ILuaUIComponent item in m_comps.Values)
        {
            item._csharp_cb_on_enable();
        }
    }

    private void OnDisable()
    {
        foreach (CL_ILuaUIComponent item in m_comps.Values)
        {
            item._csharP_cb_on_disable();
        }
    }

    private void OnDestroy()
    {
        foreach (CL_ILuaUIComponent item in m_comps.Values)
        {
            item._csharp_cb_on_destroy();
        }
        m_comps.Clear();
    }

    void text()
    {

    }
}

public interface CL_ILuaUIComponent
{
    Int64 unique_id { get; set; }
    void _csharp_cb_on_destroy();
    void _csharp_cb_on_enable();
    void _csharP_cb_on_disable();
}
