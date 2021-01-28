#!/bin/bash

server_name=$1
is_all=false
if [ -z ${server_name} ];then
    is_all=true
fi

{% if not is_win_platform %}
  {%- for svr_help in svr_help_list  %}
if [ ${is_all} = true -o "${server_name}" == "{{ svr_help.get_name() }}"  ]; then
    {{ svr_help.get_work_dir() }}/start.sh
fi
  {%- endfor %}
{% endif %}

{% if is_win_platform %}
  {%- for svr_help in svr_help_list  %}

  {%- endfor %}
{% endif %}
