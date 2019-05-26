
AuthState = {
    Free = 1,
}

AuthTask = AuthTask or class("AuthTask")

function AuthTask:cotr()
    self.netid = netid
    self.state = AuthState.Free
    self.cb_fn = nil

end