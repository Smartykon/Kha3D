#version 450

#include "normals.inc.glsl"

in vec3 norm;
in vec2 tex;

uniform sampler2D erde1;
uniform sampler2D erde2;

layout(location = 0) out vec4 frag;
layout(location = 1) out vec4 normals;

void main() {
	vec4 frag1 = texture(erde1, vec2(tex.x * 3, (1 - tex.y) * 3));
    vec4 frag2 = texture(erde2, vec2(tex.x * 7, (1 - tex.y) * 7));
	normals = vec4(encodeNormal(norm.xyz), 1.0);
	frag = (frag1 + frag2) * 0.5;
}
