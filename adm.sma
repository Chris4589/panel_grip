#include <admin_panel>

var fw_LoginAdmin;

var const authUser[] = "chris";
var const authPassword[] = "123456789";

var const urlBase[] = "http://198.12.74.204:5050";

var authToken[400], idServer;

var bool:authLoged;

function give_admin(id) {
	if (!is_user_connected(id)) {
		server_print("El player no esta conectado");
		return;
	}
	var GripResponseState:responseState = grip_get_response_state();
	if (responseState != GripResponseStateSuccessful) {
		server_print("Response Status Faild: [ %d ]", responseState);
		return;
	}

	var GripHTTPStatus:status = grip_get_response_status_code();

	if (!(GripHTTPStatusOk <= status <= GripHTTPStatusPartialContent)) {
		server_print("Code Status [ %d ]", status);
		return;
	}

	var responses[1024];
	var GripJSONValue:body = grip_json_parse_response_body(responses, charsmax(responses));

	if (body == Invalid_GripJSONValue) {
		server_print("La respuesta esperada no es un JSON");
		return;
	}

	if (isError(body)) {
		server_print("Hubo un error en la peticion a node.");
		return;
	}
	var GripJSONValue:msg = grip_json_object_get_value(body, "msg");

	if (!isArrayValid(msg)) {
		server_print("El usuario no es admin.");
		return;
	}

	var role[32], authid[32], flags[32], createdAt[50];
	var GripJSONValue:value = grip_json_array_get_value(msg, 0);
	grip_json_object_get_string(value, "role", role, charsmax(role));
	grip_json_object_get_string(value, "authid", authid, charsmax(authid));
	grip_json_object_get_string(value, "flags", flags, charsmax(flags));
	grip_json_object_get_string(value, "createdAt", createdAt, charsmax(createdAt));

	server_print("/*******************************************/");
	server_print("Admin cargado.");
	server_print("role: [ %s ]", role);
	server_print("authid: [ %s ]", authid);
	server_print("flags: [ %s ]", flags);
	server_print("createdAt: [ %s ]", createdAt);
	server_print("/*******************************************/");

	set_admin(id, flags);

	grip_destroy_json_value(value);
}

function check_isAdmin(id, const authid[]) {

	if (!authLoged) {
		server_print("No te haz logueado a tu cuenta en %s.", urlBase);
		return;
	}

	var url[200];
	formatex(url, charsmax(url), "%s/admins/server?authid=%s&fk_ServerId=%d", urlBase, authid, idServer);

	var GripRequestOptions:options = grip_create_default_options();
	grip_options_add_header(options, "Content-Type", "application/json");
	grip_options_add_header(options, "token", authToken);

	grip_request(url, Empty_GripBody, GripRequestTypeGet, "give_admin", options, id);
}

function set_admin(id, const flags[]) {
	if (!(1 <= id <= MAX_PLAYERS)) {
		console_print(0, "Error: El player debe estar en un rango de 1 a 32");
		return false;
	}
	//hacer fw_pre
	set_user_flags(id, read_flags(flags));

	var ret;
	ExecuteForward(fw_LoginAdmin, ret, id);
	return true;
}

function handlerAuth() {
	var GripHTTPStatus:status = grip_get_response_status_code();

	if (!(GripHTTPStatusOk <= status <= GripHTTPStatusPartialContent)) {
		server_print("Code Status [ %d ]", status);
		return;
	}

	var responses[1024];
	var GripJSONValue:body = grip_json_parse_response_body(responses, charsmax(responses));

	if (body == Invalid_GripJSONValue) {
		server_print("La respuesta esperada no es un JSON");
		return;
	}

	if (isError(body)) {
		server_print("Hubo un error en la peticion a node.");
		return;
	}

	var GripJSONValue:msg = grip_json_object_get_value(body, "msg");

	if (msg == Invalid_GripJSONValue) {
		server_print("La respuesta de msg no es un JSON");
		return;
	}

	grip_json_object_get_string(msg, "token", authToken, charsmax(authToken));
	server_print("your server token is [ %s ]", authToken);
	grip_destroy_json_value(msg);

	if (!authLoged) {
		getServer();
	}
	authLoged = true;
}

function renew_token() {

	if (!authLoged) {
		server_print("No te haz logueado a tu cuenta en %s.", urlBase);
		return;
	}
	
	var url[200];
	formatex(url, charsmax(url), "%s/login/renew/", urlBase);

	var GripRequestOptions:options = grip_create_default_options();
	grip_options_add_header(options, "Content-Type", "application/json");
	grip_options_add_header(options, "token", authToken);

	grip_request(url, Empty_GripBody, GripRequestTypeGet, "handlerAuth", options);
}

function auth() {
	var url[200];
	formatex(url, charsmax(url), "%s/login/", urlBase);

	var GripJSONValue:object = grip_json_init_object();
	grip_json_object_set_string(object, "user", authUser);
	grip_json_object_set_string(object, "password", authPassword);

	var GripBody:body = object != Invalid_GripJSONValue ? grip_body_from_json(object) : Empty_GripBody;

	var GripRequestOptions:options = grip_create_default_options();
	grip_options_add_header(options, "Content-Type", "application/json");
	grip_options_add_header(options, "User-Agent", "Grip");

	grip_request(url, body, GripRequestTypePost, "handlerAuth", options);
}


function client_putinserver(id) {
	new authid[50];
	get_user_authid(id, authid, charsmax(authid));

	check_isAdmin(id, authid);
}

function handlerServer() {
	var GripHTTPStatus:status = grip_get_response_status_code();

	if (!(GripHTTPStatusOk <= status <= GripHTTPStatusPartialContent)) {
		server_print("Code Status [ %d ]", status);
		return;
	}

	var responses[1024];
	var GripJSONValue:body = grip_json_parse_response_body(responses, charsmax(responses));

	if (body == Invalid_GripJSONValue) {
		server_print("La respuesta esperada no es un JSON");
		return;
	}

	if (isError(body)) {
		server_print("Hubo un error en la peticion a node.");
		return;
	}

	var GripJSONValue:msg = grip_json_object_get_value(body, "msg");

	if (msg == Invalid_GripJSONValue) {
		server_print("La respuesta de msg no es un JSON");
		return;
	}

	idServer = grip_json_object_get_number(msg, "id");
	server_print("your server id is [ %d ]", idServer);
	grip_destroy_json_value(msg);
}

function getServer() {
	var url[200], address[50];
	get_cvar_string("net_address", address, charsmax(address));
	formatex(url, charsmax(url), "%s/servers/Ip?ipServer=%s", urlBase, address);

	var GripRequestOptions:options = grip_create_default_options();
	grip_options_add_header(options, "Content-Type", "application/json");
	grip_options_add_header(options, "token", authToken);

	grip_request(url, Empty_GripBody, GripRequestTypeGet, "handlerServer", options);
}

function plugin_init() {
	register_plugin("Rest Admin", "0.1b", "Hypnotize");

	fw_LoginAdmin = CreateMultiForward("fw_LoginPost", ET_IGNORE, FP_CELL);

	authLoged = false;

	set_task(1.0, "auth", _, _, _, "c");
	set_task(120.0, "renew_token", _, _, _, "d");
}
