

TestRedisClient = TestRedisClient or class("TestRedisClient", ServiceLogic)

function TestRedisClient:ctor(logic_mgr, logic_name)
    TestRedisClient.super.ctor(self, logic_mgr, logic_name)
    self.timer_proxy = nil
    self.redis_client = nil
end

function TestRedisClient:init()
    TestRedisClient.super.init(self)
    self.redis_client = RedisClient:new(true, "127.0.0.1:7000", "xiaolzz", 1, 3000, 3000)
end

function TestRedisClient:start()
    TestRedisClient.super.start(self)
    self.timer_proxy:release_all()
    local Tick_Span_Ms = 1 * 1000
    self.timer_proxy:firm(Functional.make_closure(self._on_tick, self), Tick_Span_Ms, -1)
    self.redis_client:start()
end

function TestRedisClient:stop()
    TestRedisClient.super.stop(self)
    self.redis_client:stop()
    self.timer_proxy:release_all()
end

function TestRedisClient:_on_tick()
    self.redis_client:command(1, function(ret)
        log_debug("set foo result %s", ret)
    end, "set foo %d", 100)

    self.redis_client:command(1, function(ret)
        log_debug("get foo result %s", ret)
    end, "get foo")

    local is_ok, p_buf = PROTO_PARSER:encode(ProtoId.req_login_game, {
        token = "token_1",
        timestamp = 1,
        platform = "platform_1",
    })
    log_debug("p_buf is %s %s", type(p_buf), p_buf)
    self.redis_client:binary_command(1, function(ret)
        log_debug("binary command result %s", ret)
    end,"set %b %b ", "hello", p_buf)

    self.redis_client:array_command(1, function(ret)
        if ret.reply then
            local is_ok, tb = PROTO_PARSER:decode(ProtoId.req_login_game, ret.reply.value)
            log_debug("array command result %s \n decode tb is %s", ret, tb)
        else
            log_debug("array command result %s", ret)
        end
    end, { "  get", "hello" })

    self.redis_client:on_tick()
end

