local files = {

    -- libs
    {
        files =
        {
            "rapidjson",
            "pb",
            "lpeg",
            "lfs",
        },
        includes =
        {
            "libs.include",
        }
    },

    "common.init_global_vars",
}
return files