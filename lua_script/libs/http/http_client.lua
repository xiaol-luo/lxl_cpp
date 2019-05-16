
HttpClient = HttpClient or {}

function HttpClient.example_rsp_fn(id_int64, rsp_state, heads_map, body_str)
    -- log_debug("HttpClient.example_rsp_fn id_int64:%s rsp_state:%s, heads_map:%s, body_str:%s", id_int64, rsp_state, heads_map, body_str)
end

function HttpClient.example_event_fn(id_int64, err_type_enum, err_num_int)
    -- log_debug("HttpClient.example_event_fn id_int64:%s err_type_enum:%s err_num_int:%s", id_int64, err_type_enum, err_num_int)
end

function HttpClient.get(url, rsp_fn, event_fn, heads_tb)
    if not url then
        return 0
    end
    rsp_fn = rsp_fn or HttpClient.example_rsp_fn
    event_fn = event_fn or HttpClient.example_event_fn
    heads_tb = heads_tb or {}
    return native.http_get(url, heads_tb, rsp_fn, event_fn)
end

function HttpClient.delete(url, rsp_fn, event_fn, heads_tb)
    if not url then
        return 0
    end
    rsp_fn = rsp_fn or HttpClient.example_rsp_fn
    event_fn = event_fn or HttpClient.example_event_fn
    heads_tb = heads_tb or {}
    return native.http_delete(url, heads_tb, rsp_fn, event_fn)
end

function HttpClient.put(url, content_str, rsp_fn, event_fn, heads_tb)
    if not url then
        return 0
    end
    content_str = content_str or ""
    rsp_fn = rsp_fn or HttpClient.example_rsp_fn
    event_fn = event_fn or HttpClient.example_event_fn
    heads_tb = heads_tb or {}
    return native.http_put(url, heads_tb, tostring(content_str), rsp_fn, event_fn)
end

function HttpClient.post(url, content_str, rsp_fn, event_fn, heads_tb)
    if not url then
        return 0
    end
    content_str = content_str or ""
    rsp_fn = rsp_fn or HttpClient.example_rsp_fn
    event_fn = event_fn or HttpClient.example_event_fn
    heads_tb = heads_tb or {}
    return native.http_post(url, heads_tb, tostring(content_str), rsp_fn, event_fn)
end

-- TODO: 要做得更好需要写好event_fn
function HttpClient.co_get(url, heads_tb)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    local seq = HttpClient.get(url, new_coroutine_callback(co), nil, heads_tb)
    if seq > 0 then
        return ex_coroutine_yield(co)
    else
        return false, string.format("HttpClient.co_get fail, seq=%s", seq)
    end
end

function HttpClient.co_delete(url, heads_tb)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    local seq = HttpClient.delete(url, new_coroutine_callback(co), nil, heads_tb)
    if seq > 0 then
        return ex_coroutine_yield(co)
    else
        return false, string.format("HttpClient.co_delete fail, seq=%s", seq)
    end
end

function HttpClient.co_put(url, content_str, heads_tb)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    local seq = HttpClient.put(url, content_str, new_coroutine_callback(co), nil, heads_tb)
    if seq > 0 then
        return ex_coroutine_yield(co)
    else
        return false, string.format("HttpClient.co_put fail, seq=%s", seq)
    end
end

function HttpClient.co_post(url, content_str, heads_tb)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    local seq = HttpClient.post(url, content_str, new_coroutine_callback(co), nil, heads_tb)
    if seq > 0 then
        return ex_coroutine_yield(co)
    else
        return false, string.format("HttpClient.co_post fail, seq=%s", seq)
    end
end
