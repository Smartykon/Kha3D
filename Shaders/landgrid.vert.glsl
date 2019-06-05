#version 450

in vec3 pos;
in vec3 normal;
in vec2 texcoord;

uniform mat4 mvp;
uniform sampler2D heights;

out vec3 norm;
out vec2 tex;

float f(float x, float z) {
	return texture(heights, vec2(x, z)).r * 50.0;
}

void main() {
	norm = normal;
	tex = texcoord;
	gl_Position = mvp * vec4(pos.x, pos.y, pos.z, 1.0);
}
