#version 450

in vec2 pos;
in vec2 tex;
uniform mat4 projectionMatrix;
out vec2 texcoord;

void main() {
	texcoord = tex;
	gl_Position = projectionMatrix * vec4(pos.x, pos.y, -5.0, 1.0);
}
