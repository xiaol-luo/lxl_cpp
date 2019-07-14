
import sys
import jinja2
import os
import argparse

from global_def import *
import opera


def parse_args(input_args):
    arg_parse = argparse.ArgumentParser()
    arg_parse.add_argument("opera", choices=[
        Opera_Create,
        Opera_Start,
        Opera_Stop,
        Opera_Ps,
    ], help="operation to be execute")
    arg_parse.add_argument("zone", help="zone need to like format {name}_{num}")
    arg_parse.add_argument("--code_dir", help="code directory located")
    arg_parse.add_argument("--exe_dir", help="service.exe located directory")

    ret = arg_parse.parse_args(input_args)
    return ret


def opera_create_zone(parse_ret):
    print("opera_create_zone")
    opera.create_zone(parse_ret)


def opera_start_zone(parse_ret):
    print("opera_start_zone")


def opera_stop_zone(parse_ret):
    print("opera_stop_zone")


def opera_ps_zone(parse_ret):
    print("opera_ps_zone")


if __name__ == "__main__":
    parse_ret = parse_args(sys.argv[1:])

    opera_fns = {
        Opera_Create: opera_create_zone,
        Opera_Start: opera_start_zone,
        Opera_Stop: opera_stop_zone,
        Opera_Ps: opera_ps_zone,
    }
    for (k, v) in vars(parse_ret).items():
        print("k,v {0}, {1}".format(k, v))
    selected_fn = opera_fns[parse_ret.opera]
    selected_fn(parse_ret)


