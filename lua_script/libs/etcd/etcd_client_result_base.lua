
EtcdClientResultBase = EtcdClientResultBase or class("EtcdClientResultBase")

function EtcdClientResultBase:ctor()
    self.err_num = 0
    self.err_str = ""
    self.detail = nil
end

function EtcdClientResultBase:prase_from_json(json_str)
    self.detail = rapidjson.decode(json_str)
end


