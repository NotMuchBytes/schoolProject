shader_type canvas_item;

uniform float campaign_mode = 1.0;
uniform float route_progress = 0.0;
uniform float antigonus_blend = 0.0;
uniform float ptolemy_blend = 0.0;
uniform float seleucus_blend = 0.0;

uniform vec4 campaign_color : source_color = vec4(0.80, 0.43, 0.16, 1.0);
uniform vec4 antigonus_color : source_color = vec4(0.18, 0.52, 0.29, 1.0);
uniform vec4 ptolemy_color : source_color = vec4(0.48, 0.22, 0.60, 1.0);
uniform vec4 seleucus_color : source_color = vec4(0.89, 0.35, 0.40, 1.0);


float rectangle_mask(vec2 uv, vec4 bounds) {
	return step(bounds.x, uv.x) * step(uv.x, bounds.y)
		* step(bounds.z, uv.y) * step(uv.y, bounds.w);
}


void fragment() {
	// In a CanvasItem fragment, COLOR already contains the texture sample.
	vec4 sampled = COLOR;

	// Shape draw calls use Godot's 1x1 white texture; the actual map has a tiny
	// texel size. This keeps route, frame, marker, and vignette draws unchanged.
	float map_draw = 1.0 - step(0.01, TEXTURE_PIXEL_SIZE.x);
	float whiteness = min(sampled.r, min(sampled.g, sampled.b));
	float land_pixel = step(0.48, whiteness) * map_draw;

	// Masks follow the supplied block-map layout. The land-pixel mask clips all
	// color at the original coastline, leaving its blue seas and black ink exact.
	float asia_minor = rectangle_mask(UV, vec4(0.135, 0.355, 0.155, 0.405));
	float egypt = rectangle_mask(UV, vec4(0.0, 0.325, 0.49, 1.0));
	float ptolemaic_levant = rectangle_mask(UV, vec4(0.225, 0.345, 0.41, 0.67));
	float northern_levant = rectangle_mask(UV, vec4(0.29, 0.405, 0.265, 0.53));
	float mesopotamia = rectangle_mask(UV, vec4(0.34, 0.57, 0.22, 0.61));
	float persia = rectangle_mask(UV, vec4(0.48, 0.975, 0.16, 0.74));

	// Keep the southern Arabian peninsula and India outside Seleucus's fill.
	mesopotamia *= step(UV.y, 0.75 - 0.42 * UV.x);
	persia *= 1.0 - step(0.74, UV.y);
	persia *= 1.0 - (step(0.87, UV.x) * step(0.36, UV.y));

	vec3 tinted = sampled.rgb;
	float tint_amount = 0.0;
	if (campaign_mode > 0.5) {
		float asia_reveal = smoothstep(0.02, 0.22, route_progress) * asia_minor;
		float egypt_reveal = smoothstep(0.24, 0.40, route_progress) * egypt;
		float south_reveal = smoothstep(0.16, 0.34, route_progress) * ptolemaic_levant;
		float north_reveal = smoothstep(0.38, 0.52, route_progress) * northern_levant;
		float iraq_reveal = smoothstep(0.42, 0.66, route_progress) * mesopotamia;
		float persia_reveal = smoothstep(0.55, 0.92, route_progress) * persia;
		float campaign_reveal = max(max(max(asia_reveal, egypt_reveal), max(south_reveal, north_reveal)), max(iraq_reveal, persia_reveal));
		tint_amount = campaign_reveal * land_pixel * 0.38;
		tinted = mix(sampled.rgb, campaign_color.rgb, tint_amount);
	} else {
		float antigonus = asia_minor * antigonus_blend;
		float ptolemy = max(egypt, ptolemaic_levant) * ptolemy_blend;
		float seleucus = max(northern_levant, max(mesopotamia, persia)) * seleucus_blend;
		float total = max(antigonus, max(ptolemy, seleucus));
		vec3 territory_color = antigonus_color.rgb;
		if (ptolemy > antigonus && ptolemy >= seleucus) {
			territory_color = ptolemy_color.rgb;
		} else if (seleucus > antigonus && seleucus > ptolemy) {
			territory_color = seleucus_color.rgb;
		}
		tint_amount = total * land_pixel * 0.64;
		tinted = mix(sampled.rgb, territory_color, tint_amount);
	}

	COLOR = vec4(tinted, sampled.a);
}
