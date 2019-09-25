
CoroutineExMgr = CoroutineExMgr or {}
CoroutineExMgr.cos = CoroutineExMgr.cos or {}
CoroutineExMgr.delay_execute_fns = CoroutineExMgr.delay_execute_fns or {}

local self = CoroutineExMgr

function CoroutineExMgr.start()
    CoroutineExMgr.stop()
    self.cos = {}
    self.delay_execute_fns = {}
end

function CoroutineExMgr.stop()
    self.cos = {}
end

function CoroutineExMgr.get_co(key)
    return self.cos[key]
end

function CoroutineExMgr.get_running()
    local co = tostring(coroutine.running())
    return self.get_co(co)
end

function CoroutineExMgr.create_co(main_logic, over_cb)
    local co_ex = CoroutineEx:new(main_logic, over_cb)
    self.cos[co_ex:get_key()] = co_ex
    return co_ex
end

function CoroutineExMgr.kill(key, kill_reason)
    local co_ex = self.get_co(key)
    if co_ex then
        co_ex:kill(kill_reason)
    end
end


function CoroutineExMgr.on_frame()
    local dead_keys = {}
    for k, v in pairs(self.cos) do
        if CoroutineState.Dead == v:status() then
            dead_keys[k] = v
        end
    end
    for k, v in pairs(dead_keys) do
        self.cos[k] = nil
        v:trigger_over_cb()
    end

    local delay_execute_fns = self.delay_execute_fns
    self.delay_execute_fns = {}
    for _, fn in ipairs(delay_execute_fns) do
        Functional.safe_call(fn)
    end
end


function CoroutineExMgr.add_delay_execute_fn(fn)
    table.insert(self.delay_execute_fns, fn)
end


