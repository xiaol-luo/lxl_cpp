
AuthState = {
    Free = 1,
}

AuthItem = AuthItem or class("AuthItem")

function AuthItem:cotr()
    self.netid = netid
    self.state = AuthState.Free
end