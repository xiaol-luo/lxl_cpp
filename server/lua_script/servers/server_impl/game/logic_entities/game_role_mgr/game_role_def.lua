

Game_Role_Const = {}
Game_Role_Const.save_db_span_sec = 30

Game_Role_Const.after_n_secondes_release_all_role = 10
Game_Role_Const.check_match_world_role_span_sec = 5
Game_Role_Const.check_match_world_role_count_per_rpc_query = 100

Game_Role_State = {
    free = "free",
    load_from_db = "load_from_db",
    in_game = "in_game",
    in_error = "in_error",
}


Game_Role_Module_Name = {}
Game_Role_Module_Name.base_info = "base_info"


Game_Role_Data_Struct_Version = {}
Game_Role_Data_Struct_Version.game_role = 1
Game_Role_Data_Struct_Version.base_info = 1