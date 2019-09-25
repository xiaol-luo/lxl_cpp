
HttpMethod =
{
    Get = "Get",
    Post = "Post",
    Put = "Put",
    Delete = "Delete",
    Head = "Head",
}

function make_http_query_url(host, method, params)
    local param_strs = {}
    if IsTable(params) then
        for k, v in pairs(params) do
            local str = string.format("%s=%s", k, v)
            table.insert(param_strs, str)
        end
    end
    local query_url = string.format("%s/%s",
            string.rtrim(host, "/"),
            string.lrtrim(method, "/"))
    if #param_strs > 0 then
       query_url = string.format("%s?%s", query_url, table.concat(param_strs, "&"))
    end
    return query_url
end

function is_rsp_ok(rsp_state)
    return "ok" == string.lower(rsp_state)
end