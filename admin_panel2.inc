#include <amxmisc>
//#include <reapi>
#include <grip>

#pragma semicolon 1

#define function public
#define var new
#define registerCommand register_clcmd
#define admin_init register_plugin
#define OnStart plugin_init
#define CreateNatives plugin_natives

stock isError(GripJSONValue:body) {
	var error, GripJSONValue:fieldError = grip_json_object_get_value(body, "err");

	error = grip_json_get_bool(fieldError);
	grip_destroy_json_value(fieldError);

	if (error) {
		return true;
	}
	return false;
}

stock isArrayValid(GripJSONValue:msg) {
	if (grip_json_array_get_count(msg) == 0) {
		server_print("grip_json_array_get_count: [ %d ]", grip_json_array_get_count(msg));
		return false;
	}
	return true;
}

stock const param1[] = "Admin Rest Panel";
stock const param2[] = "0.1b";
stock const param3[] = "Hypnotize";
