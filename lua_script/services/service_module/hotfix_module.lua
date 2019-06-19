
HotfixModule = HotfixModule or class("HotfixModule", ServiceModule)

local _ErrorNum = {
    Not_Valid_Dir = 1,
}

function HotfixModule:ctor(module_mgr, module_name)
    HotfixModule.super.ctor(self, module_mgr, module_name)
    self.hotfix_dir = nil
    self.check_sec = 0
    self.Check_Span_Sec = 2
    self.file_attrs = nil
end

function HotfixModule:init(hotfix_dir)
    HotfixModule.super.init(self)
    self.hotfix_dir = hotfix_dir
end

function HotfixModule:start()
    if "directory" ~= lfs.attributes(self.hotfix_dir, "mode") then
        self.error_num = _ErrorNum.Not_Valid_Dir
        self.error_msg = string.format("%s is not a valid dir", self.hotfix_dir)
    else
        HotfixModule.super.start(self)
        self.file_attrs = self:list_files_attr()
    end
end

function HotfixModule:on_update()
    local now_sec = logic_sec()
    if now_sec - self.check_sec >= self.Check_Span_Sec then
        self.check_sec = now_sec
        local old_file_attr = self.file_attrs
        local new_file_attr = self:list_files_attr()
        self.file_attrs = new_file_attr
        local need_hotfix_files = {}
        for file_path, attr in pairs(new_file_attr) do
            local need_hotfix = false
            repeat
                if "file" ~= attr.mode then
                    break
                end
                local old_attr = old_file_attr[file_path]
                if not old_attr then
                    need_hotfix = true
                    break
                end
                if attr.modification > old_attr.modification then
                    need_hotfix = true
                end
            until true
            if need_hotfix then
                table.insert(need_hotfix_files, { file_path=file_path, attr=attr })
            end
        end
        table.sort(need_hotfix_files, function(a, b) return a.attr.modification <= b.attr.modification end)
        for _, v in pairs(need_hotfix_files) do
            Functional.safe_call(self.do_file, self, v.file_path)
        end
    end
end

function HotfixModule:list_files_attr()
    local ret = {}
    for it in lfs.dir(self.hotfix_dir) do
        local file_path = path.combine(self.hotfix_dir, it)
        local file_attr = lfs.attributes(file_path)
        if "file" == file_attr.mode then
            ret[file_path] = file_attr
        end
    end
    return ret
end

function HotfixModule:do_file(file_path)
    local fd = io.open(file_path)
    local file_content = fd:read("a")
    fd:close()
    local lf, error_msg = load(file_content)
    if not lf then
        log_error("HotfixModule:do_file fail! file:%s, error_msg:%s", file_path, error_msg)
        return
    end
    lf()
end


