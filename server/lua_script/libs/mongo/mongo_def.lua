
function mongo_extract_oid(doc)
    if not doc or not doc["_id"] or not doc["_id"]["$oid"] then
        return nil
    end
    return doc["_id"]["$oid"]
end

function mongo_gen_oid(id_str)
    local ret = {
        ["$oid"] = id_str
    }
    return ret
end