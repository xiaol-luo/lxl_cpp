
AppStateWaitTask = AppStateWaitTask or class("AppStateWaitTask", AppStateBase)

function AppStateWaitTask:ctor(state_mgr, main_logic)
    AppStateWaitTask.super.ctor(self, state_mgr, App_State_Name.wait_task, main_logic)
end

