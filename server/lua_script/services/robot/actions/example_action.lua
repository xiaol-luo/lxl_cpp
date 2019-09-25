

ExampleAction = ExampleAction or class("ExampleAction", ServiceLogic)

function ExampleAction:ctor(logic_mgr, logic_name)
    ExampleAction.super.ctor(self, logic_mgr, logic_name)
    self.timer_proxy = nil
    self.cnn = nil
end

function ExampleAction:init()
    ExampleAction.super.init(self)
end

function ExampleAction:start()
    ExampleAction.super.start(self)
    self.timer_proxy:release_all()
    local Tick_Span_Ms = 1 * 1000
    self.timer_proxy:firm(Functional.make_closure(self._on_tick, self), Tick_Span_Ms, -1)
    self.cnn = PidBinCnn:new()
    self.cnn:set_recv_cb(Functional.make_closure(self.on_cnn_recv, self))
    self.cnn:set_open_cb(Functional.make_closure(self._on_new_cnn, self))
    self.cnn:set_close_cb(Functional.make_closure(self._on_close_cnn, self))
    Net.connect("127.0.0.1", 31001, self.cnn)
end

function ExampleAction:stop()
    ExampleAction.super.stop(self)
    self.timer_proxy:release_all()
end

function ExampleAction._on_tick()

end

function ExampleAction.on_cnn_recv(cnn, pid, block)
    local is_ok, msg = PROTO_PARSER.decode(pid, block)

end

function ExampleAction._on_new_cnn(cnn, error_code)

end

function ExampleAction._on_close_cnn(cnn, error_code)

end

