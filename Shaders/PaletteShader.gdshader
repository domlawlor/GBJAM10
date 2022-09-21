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

// options
uniform bool invert;

const float precision = 0.01;

vec4 get_darkest(bool isInverted)
{
	if (isInverted)
		return color_lightest;
	else
		return color_darkest;
}

vec4 get_dark(bool isInverted)
{
	if (isInverted)
		return color_light;
	else
		return color_dark;
}

vec4 get_light(bool isInverted)
{
	if (isInverted)
		return color_dark;
	else
		return color_light;
}

vec4 get_lightest(bool isInverted)
{
	if (isInverted)
		return color_darkest;
	else
		return color_lightest;
}

vec4 swap_color(vec4 color)
{
	if (distance(color, default_darkest) <= precision)
		return get_darkest(invert);
	if (distance(color, default_dark) <= precision)
		return get_dark(invert);
	if (distance(color, default_light) <= precision)
		return get_light(invert);
	if (distance(color, default_lightest) <= precision)
		return get_lightest(invert);
	return color;
}

void fragment()
{
	COLOR = swap_color(textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0));
}