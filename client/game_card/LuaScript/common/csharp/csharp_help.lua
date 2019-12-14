
CSharpHelp = CSharpHelp or {}

function CSharpHelp.get_type(csharp_obj)
    local ret = nil
    if nil ~= csharp_obj then
        ret = csharp_obj:GetType()
    end
    return ret
end

function CSharpHelp.is_sub_type_of(ins_type, base_type)
    local ret = nil
    if nil ~= ins_type and nil ~= base_type then
        ret = ins_type:IsSubclassOf(base_type)
    end
    return ret
end
