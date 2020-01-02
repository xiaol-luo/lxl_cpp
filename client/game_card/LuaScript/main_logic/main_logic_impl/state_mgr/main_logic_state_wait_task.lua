
MainLogicStateWaitTask = MainLogicStateWaitTask or class("MainLogicStateWaitTask", MainLogicStateBase)

function MainLogicStateWaitTask:ctor(state_mgr)
    MainLogicStateWaitTask.super.ctor(self, state_mgr, Main_Logic_State_Name.wait_task)
end

