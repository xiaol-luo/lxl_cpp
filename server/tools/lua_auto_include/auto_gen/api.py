import jinja2
import os
import sys

_tt_env = None


def get_env():
    global _tt_env
    if not _tt_env:
        #_tt_env = jinja2.Environment(loader=jinja2.PackageLoader(__package__))
        this_file_locate_dir = None
        if getattr(sys, "fronzen", False):
            this_file_locate_dir = sys._MEIPASS
        else:
            this_file_locate_dir = os.path.dirname(__file__)
        tt_path = os.path.join(this_file_locate_dir, "templates")
        print("tt_path {}".format(tt_path))
        _tt_env = jinja2.Environment(loader=jinja2.FileSystemLoader(tt_path))

    return _tt_env


def render(tt_path, *args, **kwargs):
    tt = get_template(tt_path)
    if tt:
        return True, tt.render(*args, **kwargs)
    return False, None


def get_template(tt_path):
    env = get_env()
    tt = env.get_template(tt_path)
    return tt

