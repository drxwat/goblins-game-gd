shader_type spatial;
render_mode cull_disabled;

uniform vec4 color_top: hint_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 color_bottom: hint_color = vec4(0.0, 0.0, 0.0, 1.0);

uniform float max_sway_pitch;
uniform float max_sway_yaw;

uniform sampler2D wind_noise: hint_albedo;
uniform vec2 wind_scale = vec2(1.0, 1.0);
uniform vec3 wind_strength = vec3(0.1, 0.1, 0.1);
uniform vec3 wind_speed = vec3(0.1, 0.1, 0.1);

varying float wind;

mat3 mat3_from_axis_angle(float angle, vec3 axis) {
	float s = sin(angle);
	float c = cos(angle);
	float t = 1.0 - c;
	float x = axis.x;
	float y = axis.y;
	float z = axis.z;
	
	return mat3(
		vec3(t*x*x+c, t*x*y-s*z, t*x*z+s*y),
		vec3(t*x*y+s*z, t*y*y+c, t*y*z-s*x),
		vec3(t*x*z-s*y, t*y*z+s*z, t*z*z+c)
	);
}

void vertex() {
	NORMAL = vec3(0.0, 1.0, 0.0);
	vec3 vertex = VERTEX;
	vertex.xz *= INSTANCE_CUSTOM.x;
	vertex.y *= INSTANCE_CUSTOM.y;
	VERTEX = vertex;
	COLOR = mix(color_bottom, color_top, UV.y);
	
	mat3 to_model = inverse(mat3(WORLD_MATRIX));
	
	vec3 pos = (WORLD_MATRIX * vec4(vertex, 1.0)).xyz;
	vec2 wind_force = texture(wind_noise, (TIME * wind_speed).xz + (pos.xz * wind_scale)).xz * UV.y * wind_strength.xz;
	wind = length(wind_force);
	vec3 wind_direction = normalize(vec3(-1.0, 0.0, 0.0));
	vec3 wind_forward = to_model * wind_direction;
	vec3 wind_right = normalize(cross(wind_forward, vec3(0, 1, 0)));
	
	float sway_pitch = max_sway_pitch * wind + INSTANCE_CUSTOM.z;
	float sway_yaw = max_sway_yaw * wind + INSTANCE_CUSTOM.w;
	
	mat3 rotate_right = mat3_from_axis_angle(sway_pitch, wind_right);
	mat3 rotate_forward = mat3_from_axis_angle(sway_yaw, wind_forward);
	
	VERTEX = rotate_right * rotate_forward * vertex;
}

void fragment() {
	float side = FRONT_FACING ? 1.0 : -1.0;
	NORMAL = NORMAL * side;
	ALBEDO = COLOR.rgb;
	SPECULAR = 0.5;
	ROUGHNESS = 0.95;
	//ROUGHNESS = clamp(1.0 - (wind * 2.0), 0.0, 1.0);
}