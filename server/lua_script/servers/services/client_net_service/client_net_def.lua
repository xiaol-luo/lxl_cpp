

Client_Net_Const = {}

Client_Net_Event = {}


---@class ClientNetServiceCnnCallback
---@field on_open fun(client_net_svc:ClientNetService, netid:number):void
---@field on_close fun(client_net_svc:ClientNetService, netid:number, error_num:number):void
---@field on_recv fun(client_net_svc:ClientNetService, netid:number, pid:number, bin:string):void