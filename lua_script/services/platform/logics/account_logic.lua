
AccountLogic = AccountLogic or class("AccountLogic")

function AccountLogic:ctor(service_main)
    self.service_main = service_main
end

function AccountLogic:get_http_handle_fns()
    local ret = {}
    ret["/index"] = Functional.make_closure(AccountLogic.index, self)
    return ret
end

function AccountLogic:index(from_cnn_id, method, req_url, kv_params, body)
    local rsp_content = gen_http_rsp_content(200, "OK", {}, kv_params["xxx"])
    Net.send(from_cnn_id, rsp_content)
    Net.close(from_cnn_id)
end