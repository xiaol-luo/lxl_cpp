import auto_gen
import config

def create_zone(parse_ret):

    setting = config.get_service_setting(parse_ret.zone)
    print(setting)
    tt_all_service_config = auto_gen.get_template("service_setting/all_service_config.xml")
    print(tt_all_service_config.render(setting))
    pass


def __execute2(parse_ret):
    print("opera create execute2")
    pass
