
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

    ex_coroutine_expired(co,  10000)

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
    log_print("first cnn open", co_ok, action_name, error_num)

    ex_coroutine_expired(co,  3000)

    local user_id = math.random(1, 1)
    local auth_sn = gen_uuid()

    self:send_msg(gate_cnn, Login_Pid.req_user_login, { user_id=user_id, auth_sn=auth_sn })
    co_ok, action_name, error_num, pid, msg = ex_coroutine_yield(co)
    if not co_ok or Action_Name.cnn_on_recv ~= action_name or pid ~= Login_Pid.rsp_user_login then
        ex_coroutine_report_error(co, "gate connection is over")
        return
    end
    -- log_print("00000 recv msg", user_id, opera_id, co_ok, action_name, error_num, pid, msg)

    local role_digests = nil
    local loop_times = math.random(1, 3)
    while loop_times > 0 do
        ex_coroutine_expired(co,  3000)
        loop_times = loop_times - 1

        local opera_id = math.random(1, 2)
        -- log_print("loop opera_id loop_times ", user_id, opera_id, loop_times)

        if 1 == opera_id then
            self:send_msg(gate_cnn, Login_Pid.req_pull_role_digest, {})
        end

        if 2 == opera_id then
            self:send_msg(gate_cnn, Login_Pid.req_create_role, {})
        end

        co_ok, action_name, error_num, pid, msg = ex_coroutine_yield(co)
        if not co_ok or Action_Name.cnn_on_recv ~= action_name then
            ex_coroutine_report_error(co, "gate connection is over 1")
            return
        end
        -- log_print("1111 recv msg", user_id, opera_id, co_ok, action_name, error_num, pid, msg)
        if Login_Pid.rsp_pull_role_digest == pid then
            if Error_None == msg.error_num then
                role_digests = msg.role_digests
            end
        end
    end

    -- log_print("333333333333333")

    local role_id = nil
    if role_digests and next(role_digests) then
        role_id = role_digests[1].role_id
        -- log_print("===== try launch role ", user_id, role_id, role_digests)

        -- launch
        ex_coroutine_expired(co,  3000)
        self:send_msg(gate_cnn, Login_Pid.req_launch_role, { role_id = role_id })
        ex_coroutine_expired(co,  3000)
        co_ok, action_name, error_num, pid, msg = ex_coroutine_yield(co)
        if not co_ok or Action_Name.cnn_on_recv ~= action_name then
            ex_coroutine_report_error(co,"gate connection is over 20")
            return
        end
        log_debug("+++ recv msg userid %s opera %s co_ok %s action_time %s error_num %s pid %s msg %s",
                user_id, "launch", co_ok, action_name, error_num, pid, msg)

        -- 重连
        ex_coroutine_expired(co,  10000)
        gate_cnn:reset()
        gate_cnn = PidBinCnn:new()
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
        log_print("second cnn open", co_ok, action_name, error_num)
        -- log_print("recv msg", user_id, opera_id, co_ok, action_name, error_num, pid, msg)

        -- reconnect role
        ex_coroutine_expired(co,  3000)
        self:send_msg(gate_cnn, Login_Pid.req_reconnect_role, {
            role_id = role_id,  user_login_msg = {
                user_id = user_id,
                auth_sn = auth_sn,
            }})
        ex_coroutine_expired(co,  3000)
        co_ok, action_name, error_num, pid, msg = ex_coroutine_yield(co)
        if not co_ok or Action_Name.cnn_on_recv ~= action_name then
            ex_coroutine_report_error(co,"gate connection is over 21")
            return
        end
        log_debug("--- recv msg userid %s opera %s co_ok %s action_time %s error_num %s pid %s msg %s",
                user_id, "reconnect_role", co_ok, action_name, error_num, pid, msg)

        -- logout
        ex_coroutine_expired(co,  3000)
        self:send_msg(gate_cnn, Login_Pid.req_logout_role, { role_id = role_id })
        co_ok, action_name, error_num, pid, msg = ex_coroutine_yield(co)
        if not co_ok or Action_Name.cnn_on_recv ~= action_name then
            ex_coroutine_report_error(co,"gate connection is over 22")
            return
        end
        log_debug("xxx recv msg userid %s opera %s co_ok %s action_time %s error_num %s pid %s msg %s",
                user_id, "logout", co_ok, action_name, error_num, pid, msg)
    end

    if false and role_id then
        loop_times = math.random(1, 30)
        while loop_times > 0 do
            ex_coroutine_expired(co,  3000)
            loop_times = loop_times - 1

            local opera_id = math.random(1, 3)
            log_print("loop opera_id loop_times ", user_id, opera_id, loop_times)

            if 1 == opera_id then
                self:send_msg(gate_cnn, Login_Pid.req_launch_role, { role_id = role_id })
            end

            if 2 == opera_id then
                self:send_msg(gate_cnn, Login_Pid.req_logout_role, { role_id = role_id })
            end

            if 3 == opera_id then
                self:send_msg(gate_cnn, Login_Pid.req_reconnect_role, {
                    role_id = role_id,  user_login_msg = {
                        user_id = user_id,
                        auth_sn = auth_sn,
                    }})
            end

            co_ok, action_name, error_num, pid, msg = ex_coroutine_yield(co)
            if not co_ok or Action_Name.cnn_on_recv ~= action_name then
                ex_coroutine_report_error(co,  "gate connection is over 3")
                return
            end
            log_debug("++++ recv msg userid %s opera_id %s co_ok %s action_time %s error_num %s pid %s msg %s", user_id, opera_id, co_ok, action_name, error_num, pid, msg)
        end
    end

    ex_coroutine_cancel_expired(co)
    log_print("robot main logig is end")
end

---@param co CoroutineEx
function RobotTestLogin:_test_over_logic(co)
    log_print("RobotTestLogin:_test_over_logic")
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
