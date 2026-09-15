shader_type spatial;
render_mode diffuse_lambert;

// Screen-space derivatives recover each triangle's face normal so the low-poly
// SphereMesh is visibly faceted without an external model or runtime generation.
void fragment() {
	ALBEDO = vec3(0.28, 0.39, 0.52);
	ROUGHNESS = 1.0;
	NORMAL = normalize(cross(dFdy(VERTEX), dFdx(VERTEX)));
}
