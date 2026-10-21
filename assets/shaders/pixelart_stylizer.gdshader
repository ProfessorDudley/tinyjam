shader_type spatial;
render_mode unshaded;

// MIT License. Made by Leo Peltola
// Inspired by https://threejs.org/examples/webgl_postprocessing_pixel.html
//
// Renderer note (2026-10-18): this shader compiles under both Forward+ and
// Compatibility (gl_compatibility). The normal/roughness buffer
// (`hint_normal_roughness_texture`) only exists in Forward+, so that uniform
// and the highlight pass that reads it are hidden behind
// `#if CURRENT_RENDERER == RENDERER_FORWARD_PLUS` (built-in define, Godot 4.4+;
// excluded branches are removed before compilation). The Forward+ branch is the
// original v1.0.0 code, byte-for-byte. On Compatibility the same highlight is
// approximated by reconstructing a view-space normal from three depth taps.
// See PLAN.md §5.1-5.2.
//
// Halo note (2026-10-21): two fixes, both in the Compatibility branch only.
// (1) The reconstruction is faded out in the far distance, where the depth
// buffer has no precision left and the reconstructed normal is noise.
// (2) A foreground gate: only a pixel that is in front of a neighbour (a
// real silhouette edge) may produce a highlight. Without it the noise made
// the highlight term fire on background pixels next to a silhouette, and the
// quad's partial alpha painted a grey/pink halo just outside the black
// outline. The Forward+ branch is untouched and stays byte-for-byte v1.0.0.
// See PLAN.md §5.11.

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
#if CURRENT_RENDERER == RENDERER_FORWARD_PLUS
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;
#endif

uniform bool shadows_enabled = true;
uniform bool highlights_enabled = true;
uniform float shadow_strength : hint_range(0.0, 1.0, 0.01) = 0.4;
uniform float highlight_strength : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform vec3 highlight_color : source_color = vec3(1.);
uniform vec3 shadow_color : source_color = vec3(0.0);

varying mat4 model_view_matrix;


float getDepth(vec2 screen_uv, sampler2D depth_texture, mat4 inv_projection_matrix){
//	Credit: https://godotshaders.com/shader/depth-modulated-pixel-outline-in-screen-space/
	float raw_depth = texture(depth_texture, screen_uv)[0];
#if CURRENT_RENDERER == RENDERER_FORWARD_PLUS
	vec3 normalized_device_coordinates = vec3(screen_uv * 2.0 - 1.0, raw_depth);
#else
	vec3 normalized_device_coordinates = vec3(screen_uv, raw_depth) * 2.0 - 1.0;
#endif
    vec4 view_space = inv_projection_matrix * vec4(normalized_device_coordinates, 1.0);	
	view_space.xyz /= view_space.w;	
	return -view_space.z;
}

vec3 getPos(float depth, mat4 mvm, mat4 ipm, vec2 suv, mat4 wm, mat4 icm){
  vec4 pos = inverse(mvm) * ipm * vec4((suv * 2.0 - 1.0), depth * 2.0 - 1.0, 1.0);
  pos.xyz /= (pos.w+0.0001*(1.-abs(sign(pos.w))));
  return (pos*icm).xyz+wm[3].xyz;
}

float normalIndicator(vec3 normalEdgeBias, vec3 baseNormal, vec3 newNormal, float depth_diff){
	// Credit: https://threejs.org/examples/webgl_postprocessing_pixel.html
	float normalDiff = dot(baseNormal - newNormal, normalEdgeBias);
	float normalIndicator = clamp(smoothstep(-.01, .01, normalDiff), 0.0, 1.0);
	float depthIndicator = clamp(sign(depth_diff * .25 + .0025), 0.0, 1.0);
	return (1.0 - dot(baseNormal, newNormal)) * depthIndicator * normalIndicator;
}

#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
// Compatibility only: rebuild view-space position from the depth buffer. Uses
// OpenGL NDC (z in [-1, 1]) instead of the Vulkan one (z in [0, 1]).
vec3 getViewPos(vec2 screen_uv, mat4 inv_projection_matrix){
	float raw_depth = texture(DEPTH_TEXTURE, screen_uv)[0];
	vec3 normalized_device_coordinates = vec3(screen_uv, raw_depth) * 2.0 - 1.0;
	vec4 view_space = inv_projection_matrix * vec4(normalized_device_coordinates, 1.0);
	return view_space.xyz / view_space.w;
}

// Approximated view-space normal from 3 depth taps (centre / right / up).
vec3 reconstructNormal(vec2 screen_uv, vec2 e, mat4 inv_projection_matrix){
	vec3 p_center = getViewPos(screen_uv, inv_projection_matrix);
	vec3 p_right = getViewPos(screen_uv + vec2(1., 0.)*e, inv_projection_matrix);
	vec3 p_up = getViewPos(screen_uv + vec2(0., -1.)*e, inv_projection_matrix);
	vec3 n = normalize(cross(p_right - p_center, p_up - p_center));
	// The depth buffer runs out of precision in the far distance, so a normal
	// reconstructed there is pure noise (measured: adjacent background pixels
	// came out as (10,127,128) / (37,143,170) / (33,141,165)). That noise
	// makes the highlight term fire on background pixels next to a silhouette,
	// and the post-process quad's partial alpha then paints a grey halo just
	// outside the outline. Fade the normal to the constant far-plane normal so
	// the background cannot produce a normal difference. Forward+ needs none of
	// this: its G-buffer stores a sentinel normal for the background, so all
	// background pixels share one normal and no difference is ever produced.
	float near_weight = 1.0 - smoothstep(20.0, 60.0, length(p_center));
	return normalize(mix(vec3(0.0, 0.0, 1.0), n, near_weight));
}
#endif

void vertex(){
    model_view_matrix = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
	vec2 e = vec2(1./VIEWPORT_SIZE.xy);
	
//	Shadows
	float depth_diff = 0.0;
	float neg_depth_diff = .5;
	if (shadows_enabled) {
		float depth = getDepth(SCREEN_UV, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		float du = getDepth(SCREEN_UV+vec2(0., -1.)*e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		float dr = getDepth(SCREEN_UV+vec2(1., 0.)*e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		float dd = getDepth(SCREEN_UV+vec2(0., 1.)*e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		float dl = getDepth(SCREEN_UV+vec2(-1., 0.)*e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		depth_diff += clamp(du - depth, 0., 1.);
		depth_diff += clamp(dd - depth, 0., 1.);
		depth_diff += clamp(dr - depth, 0., 1.);
		depth_diff += clamp(dl - depth, 0., 1.);
		neg_depth_diff += depth - du;
		neg_depth_diff += depth - dd;
		neg_depth_diff += depth - dr;
		neg_depth_diff += depth - dl;
		neg_depth_diff = clamp(neg_depth_diff, 0., 1.);
		neg_depth_diff = clamp(smoothstep(0.5, 0.5, neg_depth_diff)*10., 0., 1.);
		depth_diff = smoothstep(0.2, 0.3, depth_diff);
//		ALBEDO = vec3(neg_depth_diff);
	}
	
//	Highlights
	float normal_diff = 0.;
	if (highlights_enabled) {
#if CURRENT_RENDERER == RENDERER_FORWARD_PLUS
		vec3 normal = texture(NORMAL_TEXTURE, SCREEN_UV).rgb * 2.0 - 1.0;
		vec3 nu = texture(NORMAL_TEXTURE, SCREEN_UV+vec2(0., -1.)*e).rgb * 2.0 - 1.0;
		vec3 nr = texture(NORMAL_TEXTURE, SCREEN_UV+vec2(1., 0.)*e).rgb * 2.0 - 1.0;
		vec3 nd = texture(NORMAL_TEXTURE, SCREEN_UV+vec2(0., 1.)*e).rgb * 2.0 - 1.0;
		vec3 nl = texture(NORMAL_TEXTURE, SCREEN_UV+vec2(-1., 0.)*e).rgb * 2.0 - 1.0;
		vec3 normal_edge_bias = (vec3(1., 1., 1.));
		normal_diff += normalIndicator(normal_edge_bias, normal, nu, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nr, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nd, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nl, depth_diff);
		normal_diff = smoothstep(0.2, 0.8, normal_diff);
		normal_diff = clamp(normal_diff-neg_depth_diff, 0., 1.);
//		ALBEDO = vec3(normal_diff);
#else
		vec3 normal = reconstructNormal(SCREEN_UV, e, INV_PROJECTION_MATRIX);
		vec3 nu = reconstructNormal(SCREEN_UV+vec2(0., -1.)*e, e, INV_PROJECTION_MATRIX);
		vec3 nr = reconstructNormal(SCREEN_UV+vec2(1., 0.)*e, e, INV_PROJECTION_MATRIX);
		vec3 nd = reconstructNormal(SCREEN_UV+vec2(0., 1.)*e, e, INV_PROJECTION_MATRIX);
		vec3 nl = reconstructNormal(SCREEN_UV+vec2(-1., 0.)*e, e, INV_PROJECTION_MATRIX);
		vec3 normal_edge_bias = (vec3(1., 1., 1.));
		normal_diff += normalIndicator(normal_edge_bias, normal, nu, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nr, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nd, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nl, depth_diff);
//		Only a pixel that really is in front of a neighbour (a silhouette edge)
//		may produce a highlight. A depth-rebuilt normal is noise wherever a tap
//		crosses a silhouette, so without this gate the highlight also fires on
//		background pixels next to an object - and the quad's partial alpha then
//		paints a coloured fringe there (the Compatibility screen-texture round
//		trip is not colour-exact). Forward+ needs no gate: its G-buffer stores
//		a sentinel normal for the background, so all background pixels share
//		one normal and no difference is ever produced.
		normal_diff *= step(0.0001, depth_diff);
//		Normals rebuilt from a 1px depth stencil are noisier than the Forward+
//		G-buffer normals, so a stricter threshold is used here.
		normal_diff = smoothstep(0.9, 1.5, normal_diff);
		normal_diff = clamp(normal_diff-neg_depth_diff, 0., 1.);
//		ALBEDO = vec3(normal_diff);
#endif
	}
	

	vec3 original_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	vec3 final_highlight_color = mix(original_color, highlight_color, highlight_strength);
	vec3 final_shadow_color = mix(original_color, shadow_color, shadow_strength);
	vec3 final = original_color;
	if (highlights_enabled) {
		final = mix(final, final_highlight_color, normal_diff);
	}
	if (shadows_enabled) {
		final = mix(final, final_shadow_color, depth_diff);
	}
	ALBEDO = final;

	float alpha_mask = depth_diff * float(shadows_enabled) + normal_diff * float(highlights_enabled);
	ALPHA = clamp((alpha_mask) * 5., 0., 1.);
}
