#include <amxmodx>
#include <amxmisc>
#include <grip>

#pragma semicolon 1

#define var new
#define function public

native set_user_coins(id, value);
native get_user_coins(id);

var const server[] = "a";
var const token[] = "";
var user_id = 0;
var server_id;
var role_id;
//has_flag(id, const flags[])
function plugin_init() {
	register_plugin("Buy Admin For Points", "0.1b", "Hypnotize");
	register_clcmd("say /buy_admin", "buy_admin");
	register_clcmd("say buy_admin", "buy_admin");
	register_clcmd("say_team /buy_admin", "buy_admin");
	register_clcmd("say_team buy_admin", "buy_admin");
}

function buy_admin(id) {
	if (is_user_admin(id)) {
		client_print_color(id, print_team_default, "YA ERES ADMIN HIJO DE PERRA.");
		return PLUGIN_HANDLED;
	}

	var GripJSONValue:author = grip_json_init_object();
	grip_json_object_set_string(author, "name", "Hypnotize");
	grip_json_object_set_string(author, "url", "https://www.reddit.com/r/cats/");
	grip_json_object_set_string(author, "icon_url", "https://i.imgur.com/R66g1Pe.jpg");

	var GripJSONValue:url = grip_json_init_object();
	grip_json_object_set_string(url, "url", "https://cdn.discordapp.com/avatars/429332762395279380/9f74c1068dd515806b5efe4993866310.png?size=2048");

	var GripJSONValue:url2 = grip_json_init_object();
	grip_json_object_set_string(url2, "url", "https://cdn.discordapp.com/avatars/429332762395279380/9f74c1068dd515806b5efe4993866310.png?size=2048");

	var GripJSONValue:footer = grip_json_init_object();
	grip_json_object_set_string(footer, "text", "Woah! So cool! :smirk:");
	grip_json_object_set_string(footer, "icon_url", "https://i.imgur.com/fKL31aD.jpg");


	var GripJSONValue:arrayField = grip_json_init_array();
	setField(arrayField, "Text", "More text", true);
	setField(arrayField, "Even more text", "Yup", true);
	setField(arrayField, "Use `\inline: true` parameter, if you want to display fields in the same line., More text", "Okay..", false);
	setField(arrayField, "Thanks!", "You're welcome :wink:", true);

	var GripJSONValue:embedData = grip_json_init_object();
	grip_json_object_set_value(embedData, "author", author);
	grip_json_object_set_string(embedData, "title", "Zombie Escape CSO");
	grip_json_object_set_string(embedData, "url", "https://google.com/");
	grip_json_object_set_string(embedData, "description", "Unete a mi partida");
	grip_json_object_set_string(embedData, "color", "15258703");
	grip_json_object_set_value(embedData, "fields", arrayField);
	grip_json_object_set_value(embedData, "thumbnail", url);
	grip_json_object_set_value(embedData, "image", url2);
	grip_json_object_set_value(embedData, "footer", footer);
	new GripJSONValue:arrayEmbed = grip_json_init_array();
	grip_json_array_append_value(arrayEmbed, embedData);


	var GripJSONValue:objectData = grip_json_init_object();
	grip_json_object_set_string(objectData, "username", "Hinami bot");
	grip_json_object_set_string(objectData, "avatar_url", "https://cdn.discordapp.com/avatars/429332762395279380/9f74c1068dd515806b5efe4993866310.png?size=2048");
	grip_json_object_set_string(objectData, "content", "Status Server");
	grip_json_object_set_value(objectData, "embeds", arrayEmbed);


	new GripRequestOptions:options = grip_create_default_options();
	grip_options_add_header(options, "Content-Type", "application/json");
	grip_options_add_header(options, "User-Agent", "Grip");

 	new GripBody:body = objectData != Invalid_GripJSONValue ? grip_body_from_json(objectData) : Empty_GripBody;

	grip_request(
    server,
    body,
    GripRequestTypePost,
    "handlerResponse",
    options
  );
	return PLUGIN_HANDLED;
}

public handlerResponse() {
	new GripHTTPStatus:status = grip_get_response_status_code();
	if (!(GripHTTPStatusOk  <= status <= GripHTTPStatusPartialContent )) {
	  server_print("Status Code Failed: [ %d ]", status);
	  return;
	}
	server_print("Status OK: [ %d ]", status);
}
setField(GripJSONValue:array, name[], value[], bool:inline)
{
	var GripJSONValue:FielData = grip_json_init_object();

	grip_json_object_set_string(FielData, "name", name);
	grip_json_object_set_string(FielData, "value", value);
	grip_json_object_set_bool(FielData, "inline", inline);
	grip_json_array_append_value(array, FielData);
	grip_destroy_json_value(FielData);
}

