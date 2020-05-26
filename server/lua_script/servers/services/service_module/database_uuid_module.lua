
DatabaseUuidModule = DatabaseUuidModule or class("DatabaseUuidModule", ServiceModule)

local _Const = {
    name = "name",
    last_id = "last_id",
}

local _ErrorNum = {
    Start_Db_Client_Fail = 1,
    Wait_Too_Long_To_Start = 2,
}

function DatabaseUuidModule:ctor(module_mgr, module_name)
    DatabaseUuidModule.super.ctor(self, module_mgr, module_name)
    self.hosts = nil
    self.auth_db = nil
    self.user_name = nil
    self.pwd = nil
    self.query_db = nil
    self.query_coll = nil
    self.uuid_names = nil
    self.uuid_pools = nil -- { applying_database=false, }
    self.db_client = nil
    self.Thread_Num = 3
    self.Wait_Start_Max_Second = 30
    self.Hold_Uuid_Min_Count = 20
    self.Apply_Uuid_Count_From_Database = 60
    self.timer_proxy = nil
    self.check_start_success_tid = nil
end

function DatabaseUuidModule:init(hosts, auth_db, user_name, pwd, query_db, query_coll, uuid_names)
    DatabaseUuidModule.super.init(self)
    self.hosts = hosts
    self.auth_db = auth_db
    self.user_name = user_name
    self.pwd = pwd
    self.query_db = query_db
    self.query_coll = query_coll
    self.uuid_names = uuid_names
    self.db_client = MongoClient:new(self.Thread_Num, hosts, auth_db, user_name, pwd)
    self.uuid_pools = {}
    for k, _ in pairs(self.uuid_names) do
        local v = {}
        v.name = k
        v.querying = false
        v.ids = {}
        v.ids_count = 0
        self.uuid_pools[k] = v
    end
end

function DatabaseUuidModule:start()
    self.curr_state = Service_State.Starting
    local ret = self.db_client:start()
    if not ret then
        self.error_num = _ErrorNum.Start_Db_Client_Fail
        self.error_msg = "start fail"
    else
        self.check_start_success_tid = self.timer_proxy:firm(
                Functional.make_closure(self.check_start_success, self, logic_sec()),
                1 * 1000, -1)
        for k, _ in pairs(self.uuid_names) do
            self:_apply_uuids_from_database(k, self.Apply_Uuid_Count_From_Database)
        end
    end
end

function DatabaseUuidModule:stop()
    self.curr_state = Service_State.Stopped
    self.db_client:stop()
    self.timer_proxy:release_all()
    self.check_start_success_tid = nil
end

function DatabaseUuidModule:on_update()
    self.db_client:on_tick()
end

function DatabaseUuidModule:cancel_check_start_success()
    if self.check_start_success_tid then
        self.timer_proxy:remove(self.check_start_success_tid)
        self.check_start_success_tid = nil
    end
end

function DatabaseUuidModule:check_start_success(begin_sec)
    if logic_sec() - begin_sec >= self.Wait_Start_Max_Second then
        self:cancel_check_start_success()
        if Service_State.Starting == self.curr_state then
            self.error_num = _ErrorNum.Wait_Too_Long_To_Start
            self.error_msg = "wait too long to start finish"
            return
        end
    end
    if Service_State.Starting ~= self.curr_state then
        return
    end
    self.db_client:on_tick()
    local is_all_ok = true
    for _, uuid_pool in pairs(self.uuid_pools) do
        if not next(uuid_pool.ids, nil) then
            is_all_ok = false
            break
        end
    end
    if is_all_ok then
        self.curr_state = Service_State.Started
        self:cancel_check_start_success()
    end
end

function DatabaseUuidModule:_apply_uuids_from_database(name, apply_num)
    if apply_num <= 0 then
        return
    end
    local uuid_pool = self.uuid_pools[name]
    if not uuid_pool then
        return
    end
    if uuid_pool.querying then
        return
    end
    local filter = { name=name }
    local doc = {
        ["$inc"]={ last_id=apply_num }
    }
    local opt = MongoOptFindOneAndUpdate:new()
    opt:set_upsert(true)
    opt:set_return_after(true)
    self.db_client:find_one_and_update(1, self.query_db, self.query_coll, filter, doc,
        Functional.make_closure(self._apply_uuids_from_database_cb, self, name, apply_num), opt)
    uuid_pool.querying = true
end

function DatabaseUuidModule:_apply_uuids_from_database_cb(name, apply_num, db_ret)
    if 0 ~= db_ret.error_num then
        log_error("DatabaseUuidModule:_apply_uuids_from_database_cb fail error_num:%s, error_msg:%s",
            db_ret.error_num, db_ret.error_msg)
        self:_apply_uuids_from_database(name, apply_num)
        return
    end
    local uuid_pool = self.uuid_pools[name]
    if uuid_pool then
        uuid_pool.querying = false
    end
    local db_doc = db_ret.val
    local to_id = db_doc.last_id
    local from_id = db_doc.last_id - apply_num + 1
    for i=from_id, to_id do
        self:revert(name, i)
    end
end

function DatabaseUuidModule:apply(name)
    local ret = nil
    local uuid_pool = self.uuid_pools[name]
    if uuid_pool then
        ret = next(uuid_pool.ids, nil)
        if ret then
            uuid_pool.ids[ret] = nil
            uuid_pool.ids_count = uuid_pool.ids_count - 1
            if uuid_pool.ids_count <= self.Hold_Uuid_Min_Count then
                self:_apply_uuids_from_database(uuid_pool.name, self.Apply_Uuid_Count_From_Database)
            end
        end
    end
    return ret
end

function DatabaseUuidModule:revert(name, uuid)
    local uuid_pool = self.uuid_pools[name]
    if uuid_pool then
        if not uuid_pool.ids[uuid] then
            uuid_pool.ids[uuid] = true
            uuid_pool.ids_count = uuid_pool.ids_count + 1
        end
    end
end


