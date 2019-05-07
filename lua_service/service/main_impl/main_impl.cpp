#include "main_impl.h"

const int Args_Index_Service_Name = 1;
const int Args_Index_WorkDir = 2;
const int Args_Index_Data_Dir = 3;
const int Args_Index_Config_File = 4;
const int Args_Index_Lua_Dir = 5;
const int Args_Index_Min_Value = Args_Index_Lua_Dir;

const char *Lua_File_Prepare_Env = "prepare_env.lua";
const char *Const_Lua_Args_Begin = "--lua_args_begin--";
const char *Const_Opt_Lua_Path = "-lua_path";
const char *Const_Opt_C_Path = "-c_path";
const char *Const_Opt_Data_Dir = "-data_dir";
const char *Const_Opt_Config_File = "-config_file";
const char *Const_Opt_Service_Name = "-service";
const char *Const_Opt_Native_Other_Params = "-native_other_params";

static char dot = '.';

std::string ExtractServiceName(std::string full_name)
{
	size_t pos = full_name.find_first_of(dot);
	if (std::string::npos == pos)
	{
		return full_name;
	}
	return full_name.substr(0, pos);
}

int ExtractServiceIdx(std::string full_name)
{
	size_t pos = full_name.find_first_of(dot);
	if (std::string::npos == pos || pos >= full_name.size())
	{
		return 0;
	}
	std::string val = full_name.substr(pos + 1);
	int ret = std::stoi(val);
	return ret;
}

