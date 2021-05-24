#include <amxmisc>
#include <reapi>
#include <grip>

forward fw_LoginPost(const iId);

#pragma semicolon 1

#define function public
#define var new

stock isError(GripJSONValue:body) {
	var error, GripJSONValue:fieldError = grip_json_object_get_value(body, "error");

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
	server_print("grip_json_array_get_count: [ %d ]", grip_json_array_get_count(msg));
	return true;
}
