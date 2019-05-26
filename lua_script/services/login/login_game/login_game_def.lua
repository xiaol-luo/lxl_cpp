
LoginGameState = {
    Free = 1,
    Auth = 2,
}

LoginGameItem = LoginGameItem or class("LoginGameItem")

function LoginGameItem:cotr()
    self.netid = netid
    self.state = LoginGameItem.Free
end

Login_Game_Event_Stop_Login = "Login_Game_Event_Stop_Login"