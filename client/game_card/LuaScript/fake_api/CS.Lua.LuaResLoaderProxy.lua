
CS.Lua.LuaResLoaderProxy = {}

function CS.Lua.LuaResLoaderProxy.Create()
end

function CS.Lua.LuaResLoaderProxy:GetLoadedResState(str_path)
    return resource_observer
end

function CS.Lua.LuaResLoaderProxy:LoadAsset(str_path)
    return resource_observer
end

function CS.Lua.AsyncLoadAsset:LoadAsset(str_path, fn_cb--[[(str_path, resource_observer)]])
        return resource_observer
end

function CS.Lua.AsyncLoadAsset:CoLoadAsset(str_path)
    return resource_observer
end

function CS.Lua.AsyncLoadAsset:UnloadAsset(str_path)
end

function CS.Lua.AsyncLoadAsset:Release()
end

