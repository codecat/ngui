uniform vec4 middle;
uniform vec2 dest_size;

vec4 effect(vec4 color, Image tex, vec2 c, vec2 screen_coords)
{
	vec4 ret;

	float right = dest_size.x - (1 - middle.z);
	float bottom = dest_size.y - (1 - middle.w);

	// top
	if (c.y < middle.y) {
		// left
		if (c.x < middle.x) {
			ret = Texel(tex, c);
		}

		// top
		else if (c.x >= middle.x && c.x < right) {
			float x = mod(c.x - middle.x, middle.z - middle.x);
			ret = Texel(tex, vec2(middle.x + x, c.y));
		}

		// right
		else {
			ret = Texel(tex, vec2(middle.z + c.x - right, c.y));
		}
	}

	// middle
	else if (c.y >= middle.y && c.y < bottom) {
		// left
		if (c.x < middle.x) {
			float y = mod(c.y - middle.y, middle.w - middle.y);
			ret = Texel(tex, vec2(c.x, middle.y + y));
		}

		// middle
		else if (c.x >= middle.x && c.x < right) {
			float x = mod(c.x - middle.x, middle.z - middle.x);
			float y = mod(c.y - middle.y, middle.w - middle.y);
			ret = Texel(tex, vec2(middle.x + x, middle.y + y));
		}

		// right
		else {
			float y = mod(c.y - middle.y, middle.w - middle.y);
			ret = Texel(tex, vec2(middle.z + c.x - right, middle.y + y));
		}

	// bottom
	} else {
		// left
		if (c.x < middle.x) {
			ret = Texel(tex, vec2(c.x, middle.w + c.y - bottom));
		}

		// bottom
		else if (c.x >= middle.x && c.x < right) {
			float x = mod(c.x - middle.x, middle.z - middle.x);
			ret = Texel(tex, vec2(middle.x + x, middle.w + c.y - bottom));
		}

		// right
		else {
			ret = Texel(tex, vec2(middle.z + c.x - right, middle.w + c.y - bottom));
		}
	}

	return ret * color;
}
