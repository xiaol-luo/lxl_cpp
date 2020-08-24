
UIHelp = UIHelp or {}

function UIHelp.extract_transform(root_comp_or_go)
    local root_ts = nil
    if CSharpHelp.not_null(root_comp_or_go) then
        local root_obj_type = CSharpHelp.get_type(root_comp_or_go)
        if CSharpHelp.is_null(root_ts) and root_obj_type == CSharpType.GameObject then
            root_ts = root_comp_or_go.transform
        end
        if CSharpHelp.is_null(root_ts) and CSharpHelp.is_sub_type_of(root_obj_type, CSharpType.Component) then
            root_ts = root_comp_or_go.gameObject.transform
        end
    end
    return root_ts
end

function UIHelp.get_component(comp_type, root_comp_or_go, relative_path)
    local ret = nil
    if nil ~= comp_type and CSharpHelp.not_null(root_comp_or_go) then
        local target_ts = UIHelp.find_transform(root_comp_or_go, relative_path)
        if CSharpHelp.not_null(target_ts) then
            ret = target_ts:GetComponent(comp_type)
        end
    end
    return ret
end

function UIHelp.add_component(comp_type, root_comp_or_go, relative_path)
    local ret = nil
    if nil ~= comp_type and CSharpHelp.not_null(root_comp_or_go) then
        local target_go = UIHelp.find_gameobject(root_comp_or_go, relative_path)
        if CSharpHelp.not_null(target_go) then
            ret = target_go:AddComponent(comp_type)
        end
    end
    return ret
end

function UIHelp.get_or_add_component(comp_type, root_comp_or_go, relative_path)
    local ret = UIHelp.get_component(comp_type, root_comp_or_go, relative_path)
    if CSharpHelp.is_null(ret) then
        ret = UIHelp.add_component(comp_type, root_comp_or_go, relative_path)
    end
    return ret
end

function UIHelp.find_transform(root_comp_or_go, relative_path)
    local ret = UIHelp.extract_transform(root_comp_or_go)
    if CSharpHelp.not_null(ret) and nil ~= relative_path and #relative_path > 0 then
        ret = ret:Find(relative_path)
    end
    return ret
end

function UIHelp.find_gameobject(root_comp_or_go, relative_path)
    local ret = nil
    local ts = UIHelp.find_transform(root_comp_or_go, relative_path)
    if CSharpHelp.not_null(ts) then
        ret = ts.gameObject
    end
    return ret
end

function UIHelp.attach_ui(ui_type, root_comp_or_go, relative_path)
    assert(ui_type and CSharpHelp.not_null(root_comp_or_go))
    local ret = nil
    local go = UIHelp.find_gameobject(root_comp_or_go, relative_path)
    if not go then
        log_error("UIHelp.attach_ui %s fail, can not find the game object:[%s:%s]",
                tostring(ui_type.__cname), tostring(root_comp_or_go), tostring(relative_path))
    else
        ret = ui_type:new(go)
    end
    return ret
end

function UIHelp.new_color(r, g, b, a)
    r = r or 0
    g = g or 0
    b = b or 0
    a = a or 1
    local ret = CS.UnityEngine.Color(r, g, b, a)
    log_debug("UIHelp.new_color %s", ret)
    return ret
end

function UIHelp.set_image_sprite(image, asset_path, cb_fn, is_set_size)
    if nil == image then
        return false
    end
    asset_path = asset_path or ""
    CS.Lua.LuaHelp.SetImageSprite(image, asset_path, cb_fn, is_set_size)
end

function UIHelp.set_parent(comp_or_go, parent_comp_or_go, is_active, local_pos, local_scale)
    local ts = UIHelp.extract_transform(comp_or_go)
    local parent_ts = UIHelp.extract_transform(parent_comp_or_go)
    assert(CSharpHelp.not_null(ts) and CSharpHelp.not_null(parent_ts))
    if nil == is_active then
        is_active = true
    end
    if nil == local_scale then
        local_scale = CS.UnityEngine.Vector3.one
    end
    if nil == local_pos then
        local_pos = CS.UnityEngine.Vector3.zero
    end
    ts:SetParent(parent_ts, false)
    ts.gameObject:SetActive(is_active)
    ts.localScale = local_scale
    ts.localPosition = local_pos
end

function UIHelp.set_active(root_comp_or_go, is_active)
    local ts = UIHelp.extract_transform(root_comp_or_go)
    if ts and ts.gameObject.activeSelf ~= is_active then
        ts.gameObject:SetActive(is_active)
    end
end

function UIHelp.is_active(root_comp_or_go)
    local ret = false
    local ts = UIHelp.extract_transform(root_comp_or_go)
    if ts and ts.gameObject.active then
        ret = true
    end
    return ret
end

function UIHelp.clone_gameobject(root_comp_or_go)
    local ret = nil
    local ts = UIHelp.extract_transform(root_comp_or_go)
    if CSharpHelp.not_null(ts) then
        ret = CS.Lua.LuaHelp.InstantiateGameObject(ts.gameObject)
    end
    return ret
end

function UIHelp.destroy_gameobject(go)
    if CSharpHelp.not_null(go) then
        if CSharpType.GameObject == CSharpHelp.get_type(go) then
            CS.UnityEngine.GameObject.Destroy(go)
        end
    end
end
