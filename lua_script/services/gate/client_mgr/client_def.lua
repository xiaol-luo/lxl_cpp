
ClientState = {
    Free = 0,
    Authing = 1,
    Manage_Role = 2,
    Launch_Role = 3,
    In_Game = 4,
    Releasing = 5,
    Released = 6,
}

ReqUserLoginError = {
    None = 0,
    No_Client = 1,
    State_Not_Fit = 2,
    Start_Auth_Fail = 3,
    Auth_Fail = 4,
    Coroutine_Error = 5,
}