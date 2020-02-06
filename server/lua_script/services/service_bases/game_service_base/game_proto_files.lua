
local files =
{
    [Proto_Const.Pb] =
    {
        "client_login.pb",
        "client_gate.pb",
        "gate_world.pb",
        "gate_game.pb",
        "world_game.pb",
        "match.pb",
        "room.pb",
        "game.pb",
    },
    [Proto_Const.Sproto] =
    {

    },
}

function get_game_proto_files()
    return files
end