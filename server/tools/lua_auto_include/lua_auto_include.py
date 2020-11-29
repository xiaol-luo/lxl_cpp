
import argparse
import sys
import os
import auto_gen
import codecs
from slpp import slpp

Include_File_Name = "include.lua"


def parse_args(input_args):
    arg_parse = argparse.ArgumentParser()
    arg_parse.add_argument("root", help="to travel dir")
    arg_parse.add_argument("--suffixs", action="append")
    arg_parse.add_argument("--include_dirs", action="append", help="include dirs")
    arg_parse.add_argument("--exclude_dirs", action="append", help="exclude dirs")
    arg_parse.add_argument("--exclude_files", action="append", help="exclude files")

    ret = arg_parse.parse_args(input_args)
    return ret


def extract_file_suffix(file_path):
    ret = ""
    tmp_strs = os.path.splitext(file_path)
    if len(tmp_strs) > 1:
        ret = tmp_strs[len(tmp_strs) - 1]
    return ret


def exclude_file_path(file_path, exclude_file_paths, allow_suffixs):
    ret = False
    if not ret and allow_suffixs:
        is_not_fit = True
        file_suffix = extract_file_suffix(file_path)
        if file_suffix in allow_suffixs:
            is_not_fit = False
        ret= is_not_fit
    if not ret and exclude_files:
        for item in exclude_file_paths:
            if file_path.endswith(item):
                ret = True
                break
    return ret


def exclude_dir_path(dir_path, exclude_dir_paths):
    ret = False
    if exclude_dirs:
        for item in exclude_dir_paths:
            if dir_path.startswith(item):
                ret = True
                break
    return ret


def include_dir_path(dir_path, include_dir_paths):
    ret = not include_dirs
    if include_dirs:
        for item in include_dir_paths:
            if dir_path.startswith(item):
                ret = True
                break
    return ret


def abs_join_path(p1, p2=None):
    ret = os.path.join(os.path.join(p1, p2 or "")).replace("\\", "/").rstrip("/")
    return ret


def to_lua_path(p_str):
    if p_str.endswith(".lua"):
        p_str = p_str[:-4]
    p_str = p_str.replace("\\", "/").replace("/", ".")
    return p_str


if __name__ == "__main__":
    parse_ret = parse_args(sys.argv[1:])
    for (k, v) in vars(parse_ret).items():
        print("parse_args k, v: {0}, {1}".format(k, v))
    root_dir = os.path.abspath(parse_ret.root)
    file_suffixs = None
    if parse_ret.suffixs:
        file_suffixs = {}
        for elem in parse_ret.suffixs:
            file_suffixs[elem] = True
    include_dirs = None
    if parse_ret.include_dirs:
        include_dirs= {}
        for elem in parse_ret.include_dirs:
            tmp_dir = abs_join_path(os.path.join(root_dir, elem))
            include_dirs[tmp_dir] = True
    exclude_dirs = {}
    for elem in parse_ret.exclude_dirs or []:
        tmp_dir = abs_join_path(os.path.join(root_dir, elem))
        exclude_dirs[tmp_dir] = True
    exclude_files = {Include_File_Name: True}
    for elem in parse_ret.exclude_files or []:
        exclude_files[elem] = True

    for visit_dir, child_dirs, child_files in os.walk(root_dir):
        #print("os.walk {} {} {}".format(visit_dir, child_dirs, child_files))
        visit_dir_abs_path = abs_join_path(visit_dir)
        if not include_dir_path(visit_dir_abs_path, include_dirs) or exclude_dir_path(visit_dir_abs_path, exclude_dirs):
            continue

        #visit_dir_relative_path = visit_dir_abs_path[len(root_dir):].lstrip("/")
        #print("visit_dir_relative_path {}".format(visit_dir_relative_path))
        fit_dirs = []
        fit_files = []
        for elem in child_dirs:
            tmp_abs_path = abs_join_path(visit_dir_abs_path, elem)
            if include_dir_path(tmp_abs_path, include_dirs) and not exclude_dir_path(tmp_abs_path, exclude_dirs):
                tmp_relative_path = to_lua_path(os.path.join(elem, Include_File_Name))
                fit_dirs.append(tmp_relative_path)
        for elem in child_files:
            tmp_abs_path = abs_join_path(visit_dir_abs_path, elem)
            if not exclude_file_path(tmp_abs_path, exclude_files, file_suffixs):
                tmp_relative_path = to_lua_path(os.path.join(elem))
                fit_files.append(tmp_relative_path)

        write_file = abs_join_path(visit_dir_abs_path, Include_File_Name)
        with codecs.open(write_file, 'r', 'utf-8') as f:
            f.readline()
            f.readline()
            txt_content = f.read()
            setting_tb = slpp.decode(txt_content)
            if setting_tb:
                order_fit_files = setting_tb[0].get("files", [])
                order_fit_dirs = setting_tb[0].get("includes", [])
                file_repeat_checker = {e: True for e in order_fit_files }
                dir_repeat_checker = {e: True for e in order_fit_dirs }
                for elem in fit_files:
                    if elem not in file_repeat_checker:
                        order_fit_files.append(elem)
                for elem in fit_dirs:
                    if elem not in dir_repeat_checker:
                        order_fit_dirs.append(elem)
                fit_files = order_fit_files
                fit_dirs = order_fit_dirs
        render_ret, render_content = auto_gen.render(
            "include.lua.tt", scrip_files=fit_files, include_files=fit_dirs)
        #print("render_content {}\n{}\n{} \n\n".format(render_ret, write_file, render_content))
        with codecs.open(write_file, 'w', 'utf-8') as f:
            f.write(render_content)
