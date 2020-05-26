
---@class HttpClientRspResult
---@field id string
---@field state string
---@field heads table<string, string>
---@field body string
local HttpClientRspResult = {} -- for declare

---@class HttpClientEventResult
---@field id string
---@field event_type string
---@field error_num number
local HttpClientEventResult = {} -- for declare

---@class HttpClient
HttpClient = HttpClient or {}

function HttpClient.example_rsp_fn(ret)
    -- log_debug("HttpClient.example_rsp_fn %s", ret)
end

function HttpClient.example_event_fn(ret)
    -- log_debug("HttpClient.example_event_fn %s", ret)
end

---@alias Fn_HttpClientRspCb fun(ret:HttpClientRspResult):void
---@alias Fn_HttpClientEventCb fun(ret:HttpClientEventResult):void

---@param url string
---@param rsp_fn Fn_HttpClientRspCb
---@param event_fn Fn_HttpClientEventCb
---@param heads_tb table<string, string>
function HttpClient.get(url, rsp_fn, event_fn, heads_tb)
    if not url then
        return 0
    end
    rsp_fn = rsp_fn or HttpClient.example_rsp_fn
    event_fn = event_fn or HttpClient.example_event_fn
    heads_tb = heads_tb or {}
    return native.http_get(url, heads_tb, rsp_fn, event_fn)
end

---@param url string
---@param rsp_fn Fn_HttpClientRspCb
---@param event_fn Fn_HttpClientEventCb
---@param heads_tb table<string, string>
function HttpClient.delete(url, rsp_fn, event_fn, heads_tb)
    if not url then
        return 0
    end
    rsp_fn = rsp_fn or HttpClient.example_rsp_fn
    event_fn = event_fn or HttpClient.example_event_fn
    heads_tb = heads_tb or {}
    return native.http_delete(url, heads_tb, rsp_fn, event_fn)
end

---@param url string
---@param content_str string
---@param rsp_fn Fn_HttpClientRspCb
---@param event_fn Fn_HttpClientEventCb
---@param heads_tb table<string, string>
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

---@param url string
---@param content_str string
---@param rsp_fn Fn_HttpClientRspCb
---@param event_fn Fn_HttpClientEventCb
---@param heads_tb table<string, string>
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

---@class HttpClientCallbackType
---@field Event_Callback number
---@field Response_Callback number
local HttpClientCallbackType = {
    Event_Callback = 1,
    Response_Callback = 2,
}


---@alias Fn_HttpClientCoroutineCb fun(co:CoroutineEx, cb_type:HttpClientCallbackType, ret:HttpClientRspResult)

---@return Fn_HttpClientEventCb
local make_co_fun_callback = function()
    local is_done = false
    local ret = function(co, cb_type, ret)
        -- log_debug("make_co_fun_callback %s %s", cb_type, ret)
        if not is_done and CoroutineState.Dead ~= ex_coroutine_status(co) then
            if cb_type == HttpClientCallbackType.Response_Callback then
                is_done = true
                ex_coroutine_delay_resume(co, ret)
            end
            if cb_type == HttpClientCallbackType.Event_Callback then
                if 0 ~= ret.error_num then
                    is_done = true
                    ex_coroutine_report_error(co, string.format("http query fail, event_type:%s, error_num:%s",
                            ret.event_type, ret.error_num))
                end
            end
        end
    end
    return ret
end

---@param url string
---@param heads_tb table<string, string>
function HttpClient.co_get(url, heads_tb)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    local cb_fn = make_co_fun_callback()
    local seq = HttpClient.get(
            url,
            Functional.make_closure(cb_fn, co, HttpClientCallbackType.Response_Callback),
            Functional.make_closure(cb_fn, co, HttpClientCallbackType.Event_Callback),
            heads_tb)
    if seq > 0 then
        return ex_coroutine_yield(co)
    else
        return false, string.format("HttpClient.co_get fail, seq=%s", seq)
    end
end

---@param url string
---@param heads_tb table<string, string>
function HttpClient.co_delete(url, heads_tb)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    local seq = HttpClient.delete(
            url,
            Functional.make_closure(cb_fn, co, HttpClientCallbackType.Response_Callback),
            Functional.make_closure(cb_fn, co, HttpClientCallbackType.Event_Callback),
            heads_tb)
    if seq > 0 then
        return ex_coroutine_yield(co)
    else
        return false, string.format("HttpClient.co_delete fail, seq=%s", seq)
    end
end

---@param url string
---@param content_str string
---@param heads_tb table<string, string>
function HttpClient.co_put(url, content_str, heads_tb)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    local seq = HttpClient.put(
            url,
            content_str,
            Functional.make_closure(cb_fn, co, HttpClientCallbackType.Response_Callback),
            Functional.make_closure(cb_fn, co, HttpClientCallbackType.Event_Callback),
            heads_tb)
    if seq > 0 then
        return ex_coroutine_yield(co)
    else
        return false, string.format("HttpClient.co_put fail, seq=%s", seq)
    end
end

---@param url string
---@param content_str string
---@param heads_tb table<string, string>
function HttpClient.co_post(url, content_str, heads_tb)
    local co = ex_coroutine_running()
    assert(co, "should be called in a running coroutine")
    local seq = HttpClient.post(
            url,
            content_str,
            Functional.make_closure(cb_fn, co, HttpClientCallbackType.Response_Callback),
            Functional.make_closure(cb_fn, co, HttpClientCallbackType.Event_Callback),
            heads_tb)
    if seq > 0 then
        return ex_coroutine_yield(co)
    else
        return false, string.format("HttpClient.co_post fail, seq=%s", seq)
    end
end

