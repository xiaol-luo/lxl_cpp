
RedisResult = RedisResult or class("RedisResult")

function RedisResult:cotr(real_result)
    self.real_result = real_result
end
