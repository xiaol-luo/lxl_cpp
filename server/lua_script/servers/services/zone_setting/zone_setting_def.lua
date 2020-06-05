
Zone_Setting_Const = {}

Zone_Setting_Const.db_path_zone_setting_format = "/%s/zone_setting" -- /$zone_name/zone_setting
Zone_Setting_Const.db_path_zone_allow_join_servers_format = "/%s/zone_setting/allow_join_servers" -- /$zone_name/zone_setting/allow_join_servers
Zone_Setting_Const.db_path_zone_role_min_nums_format = "/%s/zone_setting/role_min_nums" -- /$zone_name/zone_setting/role_min_nums

Zone_Setting_Event = {}
Zone_Setting_Event.zone_setting_allow_join_servers_diff = "Zone_Setting_Event.zone_setting_allow_join_servers_diff"
Zone_Setting_Event.zone_setting_role_min_nums_diff = "Zone_Setting_Event.zone_setting_role_min_nums_diff"
-- Zone_Setting_Event.zone_setting_change = "Zone_Setting_Event.zone_setting_change"

Zone_Setting_Diff = {}
Zone_Setting_Diff.upsert = "Zone_Setting_Diff.upsert"
Zone_Setting_Diff.delete = "Zone_Setting_Diff.delete"