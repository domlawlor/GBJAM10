shader_type canvas_item;

// default gb colors
//const vec3 GB_COLOR_DARKEST = vec3(15.0, 56.0, 15.0);
//const vec3 GB_COLOR_DARK = vec3(48.0, 98.0, 48.0);
//const vec3 GB_COLOR_LIGHT = vec3(139.0, 172.0, 15.0);
//const vec3 GB_COLOR_LIGHTEST = vec3(155.0, 188.0, 15.0);

uniform vec4 default_darkest;
uniform vec4 default_dark;
uniform vec4 default_light;
uniform vec4 default_lightest;

// replacement color
uniform vec4 color_darkest;
uniform vec4 color_dark;
uniform vec4 color_light;
uniform vec4 color_lightest;

const float precision = 0.1;

vec4 swap_color(vec4 color){
	if (distance(color, default_darkest) <= precision)
		return color_darkest;
	if (distance(color, default_dark) <= precision)
		return color_dark;
	if (distance(color, default_light) <= precision)
		return color_light;
	if (distance(color, default_lightest) <= precision)
		return color_lightest;
	return color;
}

void fragment() {
	COLOR = swap_color(textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0));
	
//	if (c == default_darkest) { c = color_darkest; }
//	else if (c == default_dark) { c = color_dark; }
//	else if (c == default_light) { c = color_light; }
//	else if (c == default_lightest) { c = color_lightest; }
//
//	if (c.r > )
//	COLOR.rgb = c;
}