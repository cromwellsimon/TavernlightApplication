// Hyper-V, the VM software I was using, never has a good time with graphical stuff, so I ended up just having to do this with a different engine, Godot, on my native OS. GSL (Godot Shader Language) and GLSL are ridiculously similar though so I think the point gets across the same
// Look at the demonstration video for a sample on this working

shader_type canvas_item;

// How many after images you want
uniform int trailCount: hint_range(0, 10, 1) = 5;
// This is essentially the direction that the character is facing
uniform vec2 origin = vec2(0.0, 0.5);

// The color that you want your outline to be
uniform vec4 color: source_color = vec4(1.0, 0.0, 0.0, 1.0);
// The width of the outline
uniform float width: hint_range(0.0, 10.0) = 5.0;

void vertex()
{
	// This will determine the direction to expand the vertices
	vec2 direction;
	// If we don't have a trail, then we don't need to do any expansion
	if (trailCount == 0)
	{
		direction = vec2(1, 1);
	}
	else
	{
		// I have to do some off-by-one stuff due to accounting for if trailCount == 0
		direction = vec2(1, 1.0 + float(trailCount * 2));
	}
	// Don't expand the vertices in the forward-facing direction.
	// I don't want this to expand out in all directions, only in the backward-facing direction as that's how the dash looks
	if (VERTEX.y < origin.y)
	{
		VERTEX *= direction;
	}
	
	// Expand the UV as well if we have a trail
	if (trailCount > 0)
	{
		UV.y *= float(trailCount + 1);
		// Also offset it by that same trailCount. In the case of having a trailCount of 5, this makes the UV.y range -5 to +1 instead of 0 to +6
		// 0 to 1 are the original sprite location while everything in the negative range are all of the trail counts
		// This just makes the vector math simpler since you can guarantee that everything in the 0 to 1 UV range are the original sprite
		// The original sprite is both the only sprite that we want to outline and that only sprite that we want to not have any transparency from the trailing effect applied
		UV.y -= float(trailCount);
	}
}

bool hasContraryNeighbour(vec2 uv, vec2 texture_pixel_size, sampler2D texture) {
	for (float i = -ceil(width); i <= ceil(width); i++) 
	{
		float x = abs(i) > width ? width * sign(i) : i;
		float offset = width;
		
		for (float j = -ceil(offset); j <= ceil(offset); j++) 
		{
			float y = abs(j) > offset ? offset * sign(j) : j;
			vec2 xy = uv + texture_pixel_size * vec2(x, y);
			
			if ((xy != clamp(xy, vec2(0.0), vec2(1.0)) || texture(texture, xy).a <= 0.0) == true) 
			{
				return true;
			}
		}
	}
	
	return false;
}

void fragment()
{
	// If we don't have a trail active, then don't do any of the trails or outlines
	if (trailCount != 0)
	{
		// Repeat the texture
		COLOR = texture(TEXTURE, mod(UV, vec2(1, 1)));
		if (UV.y < 0.0)
		{
			// Add the transparency the further we get away from positive numbers
			COLOR.a *= ((UV.y + float(trailCount)) / float(trailCount * 2));
		}
		else
		{
			// If the pixel is not transparent and is applicable for being outlined, then apply the outline with the color of your choice
			if ((COLOR.a > 0.0) == true && hasContraryNeighbour(UV, TEXTURE_PIXEL_SIZE, TEXTURE))
			{
				COLOR.rgb = mix(COLOR.rgb, color.rgb, color.a);
				COLOR.a += (1.0 - COLOR.a) * color.a;
			}
		}
	}
}