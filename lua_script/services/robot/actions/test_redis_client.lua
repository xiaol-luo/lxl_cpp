

TestRedisClient = TestRedisClient or class("TestRedisClient", ServiceLogic)

function TestRedisClient:ctor(logic_mgr, logic_name)
    TestRedisClient.super.ctor(self, logic_mgr, logic_name)
    self.timer_proxy = nil
    self.redis_client = nil
end

function TestRedisClient:init()
    TestRedisClient.super.init(self)
    self.redis_client = RedisClient:new(true, "127.0.0.1:7000", "", "", 1, 3000, 3000)
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
    self.redis_client:on_tick()
end

