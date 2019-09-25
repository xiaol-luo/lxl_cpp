import jinja2

_tt_env = None


def get_env():
    global _tt_env
    if not _tt_env:
        _tt_env = jinja2.Environment(loader=jinja2.PackageLoader(__package__))
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

