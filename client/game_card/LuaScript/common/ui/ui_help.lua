
UIHelp = UIHelp or {}

function UIHelp.extract_transform(root_comp_or_go)
    local root_ts = nil
    if nil ~= root_comp_or_go then
        local root_obj_type = CSharpHelp.get_type(root_comp_or_go)
        if nil == root_ts and root_obj_type == CSharpType.GameObject then
            root_ts = root_comp_or_go.transform
        end
        if nil == root_ts and CSharpHelp.is_sub_type_of(root_obj_type, CSharpType.Component) then
            root_ts = root_comp_or_go.gameObject.transform
        end
    end
    return root_ts
end

function UIHelp.get_component(comp_type, root_comp_or_go, relative_path)
    local ret = nil
    if nil ~= comp_type and nil ~= root_comp_or_go then
        local target_ts = UIHelp.find_transform(root_comp_or_go, relative_path)
        if nil ~= target_ts then
            ret = target_ts:GetComponent(comp_type)
        end
    end
    return ret
end

function UIHelp.find_transform(root_comp_or_go, relative_path)
    local ret = UIHelp.extract_transform(root_comp_or_go)
    if nil ~= ret and nil ~= relative_path and #relative_path > 0 then
        ret = ret:Find(relative_path)
    end
    return ret
end

function UIHelp.find_gameobject(root_comp_or_go, relative_path)
    local ret = nil
    local ts = UIHelp.find_transform(root_comp_or_go, relative_path)
    if nil ~= ts then
        ret = ts.gameObject
    end
    return ret
end


