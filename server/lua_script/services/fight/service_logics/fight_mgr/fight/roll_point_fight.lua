
RollPointFight = RollPointFight or class("RollPointFight", FightBase)

function RollPointFight:ctor(fight_mgr, fight_id, fight_session_id, room_id, room_client, match_cells)
    RollPointFight.super.ctor(self, fight_mgr, Fight_Type.roll_point_fight, fight_id, fight_session_id, room_id, room_client, match_cells)
    self.is_fight_over = false
    self.fight_init_sec = nil
    self.roll_record = {}
    self.fight_result = {}
    self.role_count = 0
    for _, cell in pairs(match_cells) do
        self.role_count = self.role_count + table.size(cell.roles)
    end
    self.fight_last_secs = 60 -- 60秒后结束本场fight
end

function RollPointFight:wait_release()
    return self.is_fight_over
end

function RollPointFight:_on_init()
    self.fight_init_sec = logic_sec()
    return Error_None
end

function RollPointFight:_on_bind_client(client_data)

end

function RollPointFight:_on_unbind_client(client_data)

end

function RollPointFight:_on_update()
    self:_check_fight_over()
end

function RollPointFight:_on_release()

end

function RollPointFight:_on_msg_quit_fight(client_data, pid, msg)

end

function RollPointFight:_on_msg_pull_fight_state(client_data, pid, msg)

end

function RollPointFight:_on_msg_req_fight_opera(client_data, pid, msg)
    if msg.opera == "roll" then
        self.roll_record[client_data.role_id] = math.random(1, 100)
        self:foreach_client(function(client_data)
            client_data.client:send(ProtoId.sync_roll_point_result, {
                role_roll_points = self.roll_record,
            })
        end)
        self:_check_fight_over()
    end
end

function RollPointFight:_check_fight_over()
    if self.is_fight_over then
       return
    end

    if table.size(self.roll_record) >= self.role_count then
        self.is_fight_over = true
    end
    if not self.is_fight_over and self.fight_init_sec then
        if logic_sec() - self.fight_init_sec > self.fight_last_secs then
            self.is_fight_over = true
        end
    end
    if self.is_fight_over then
        self.fight_result = {
            roll_record = self.roll_record
        }
    end
end

function RollPointFight:get_fight_result()
    return self.fight_result
end
