
local Action_Name = {}
Action_Name.cnn_on_open = "cnn_on_open"
Action_Name.cnn_on_close = "cnn_on_close"
Action_Name.cnn_on_recv = "cnn_on_recv"

local Error_None = 0

---@class RobotTestLogin : RobotBase
---@field redis_setting_online_servers RedisServerConfig
---@field mongo_setting_game MongoServerConfig
RobotTestLogin = RobotTestLogin or class("RobotTestLogin", RobotBase)


function create_robot_main(init_setting, init_args)
    return RobotTestLogin:new(init_setting, init_args)
end


function RobotTestLogin:ctor(init_setting, init_args)
    RobotTestLogin.super.ctor(self, "RobotTestLogin", init_setting, init_args)
    self._running_logic_map = RandomHash:new()
    self._gate_ip = nil
    self._gate_port = nil
    self._robot_num = 1
end

function RobotTestLogin:_on_init()
    RobotTestLogin.super._on_init(self)

    local gate_info = xml.extract_element(self.init_setting.gates.gate, "name", "gate_info")
    assert(gate_info)
    self._gate_ip = gate_info.ip
    self._gate_port = tonumber(gate_info.port)
    self._robot_num = tonumber(self.init_setting.robot_num)

    self.pto_parser:load_files(Login_Pto.pto_files)
    self.pto_parser:setup_id_to_protos(Login_Pto.id_to_pto)

    return true
end

function RobotTestLogin:_on_start()
    RobotTestLogin.super._on_start(self)
end

function RobotTestLogin:_on_frame()
    RobotTestLogin.super._on_frame(self)
    while self._running_logic_map:size() < self._robot_num do
        local co = ex_coroutine_create(
                Functional.make_closure(self._test_main_logic, self),
                Functional.make_closure(self._test_over_logic, self)
        )
        local logic_uuid = gen_uuid()
        self._running_logic_map:add(logic_uuid, co)
        ex_coroutine_start(co, co, logic_uuid)
    end

    -- log_print("RobotTestLogin:_on_frame _robot_num", self._robot_num)
end

---@param co CoroutineEx
function RobotTestLogin:_test_main_logic(co, logic_uuid)
    local co_ok, action_name, error_num, pid, msg = nil

    local co_custom_data = {}
    co_custom_data.logic_uuid = logic_uuid
    co:set_custom_data(co_custom_data)

    ---@type PidBinCnn
    local gate_cnn = PidBinCnn:new()
    gate_cnn:set_open_cb(Functional.make_closure(self._gate_cnn_on_open, self, co))
    gate_cnn:set_close_cb(Functional.make_closure(self._gate_cnn_on_close, self, co))
    gate_cnn:set_recv_cb(Functional.make_closure(self._gate_cnn_on_recv, self, co))
    Net.connect_async(self._gate_ip, self._gate_port, gate_cnn)
    co_custom_data.gate_cnn = gate_cnn
    co_ok, action_name, error_num = ex_coroutine_yield(co)
    if not co_ok or Action_Name.cnn_on_open ~= action_name or Error_None ~= error_num then
        log_print("Net.connect_async fail ", co_ok, action_name, error_num)
        return false
    end
    log_print("cnn open", co_ok, action_name, error_num)

    local loop_times = math.random(1, 20)
    while loop_times > 0 do
        loop_times = loop_times - 1

        local opera_id = math.random(1, 2)
        if 1 == opera_id then
            self:send_msg(gate_cnn, Login_Pid.req_pull_role_digest, {})
        end

        if 2 == opera_id then
            self:send_msg(gate_cnn, Login_Pid.req_create_role, {})
        end

        co_ok, action_name, error_num, pid, msg = ex_coroutine_yield(co)
        if not co_ok or Action_Name.cnn_on_recv ~= action_name then
            ex_coroutine_report_error("gate connection is over")
            return
        end
        log_print("recv msg", co_ok, action_name, error_num, pid, msg)
    end
end

---@param co CoroutineEx
function RobotTestLogin:_test_over_logic(co)
    local co_custom_data = co:get_custom_data()
    if co_custom_data.gate_cnn then
        co_custom_data.gate_cnn:reset()
    end
    self._running_logic_map:remove(co_custom_data.logic_uuid)
    -- log_print("RobotBase:_test_over_logic", co_custom_data.logic_uuid)
end

function RobotTestLogin:_gate_cnn_on_open(co, cnn, error_num)
    local co_custom_data = co:get_custom_data()
    if not co_custom_data or not co_custom_data.gate_cnn or co_custom_data.gate_cnn:netid() ~= cnn:netid() then
        return
    end
    ex_coroutine_resume(co, Action_Name.cnn_on_open, error_num)
end

function RobotTestLogin:_gate_cnn_on_close(co, cnn, error_num)
    local co_custom_data = co:get_custom_data()
    if not co_custom_data or not co_custom_data.gate_cnn or co_custom_data.gate_cnn:netid() ~= cnn:netid() then
        return
    end
    ex_coroutine_resume(co, Action_Name.cnn_on_close, error_num)
end

function RobotTestLogin:_gate_cnn_on_recv(co, cnn, pid, block)
    local co_custom_data = co:get_custom_data()
    if not co_custom_data or not co_custom_data.gate_cnn or co_custom_data.gate_cnn:netid() ~= cnn:netid() then
        return
    end

    local is_ok, msg = self.pto_parser:decode(pid, block)
    ex_coroutine_resume(co, Action_Name.cnn_on_recv, is_ok and 0 or -1, pid, msg)
end

function RobotTestLogin:send_msg(cnn, pid, msg)
    local is_ok, bin = self.pto_parser:encode(pid, msg)
    if is_ok then
        return cnn:send(pid, bin)
    end
    return false
end
