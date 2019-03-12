
HttpClient = HttpClient or {}

function HttpClient.example_rsp_fn(id_int64, url_str, heads_map, body_str, body_len)

end

function HttpClient.example_event_fn(id_int64, err_type_enum, err_num_int)

end

function HttpClient.get(url, rsp_fn, event_fn, heads_tb)
    if not url then
        return 0
    end
    rsp_fn = rsp_fn or HttpClient.example_rsp_fn
    event_fn = event_fn or HttpClient.example_event_fn
    heads_tb = heads_tb or {}
    native.http_get(url, heads_tb, rsp_fn, event_fn)
end

function HttpClient.put(url, content_str, rsp_fn, event_fn, heads_tb)
    if not url then
        return 0
    end
    content_str = content_str or ""
    rsp_fn = rsp_fn or HttpClient.example_rsp_fn
    event_fn = event_fn or HttpClient.example_event_fn
    heads_tb = heads_tb or {}
    native.http_put(url, heads_tb, tostring(content_str), rsp_fn, event_fn)
end

