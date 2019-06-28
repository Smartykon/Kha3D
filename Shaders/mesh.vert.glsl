#version 450

in vec3 pos;
in vec3 meshpos;
in float yrotate;
in vec3 normal;
//in vec2 texcoord;
in vec3 colors;

uniform mat4 mvp;

out vec3 norm;
//out vec2 tex;
out vec3 cols;

void main() {
	norm = normal;
	//tex = texcoord;
	cols = colors;
	mat3 m_yrotate = mat3(
		cos(yrotate), 0, -sin(yrotate),
	    0, 1, 0,
		sin(yrotate), 0, cos(yrotate));
	gl_Position = mvp * vec4(m_yrotate * (pos * 0.1) + meshpos, 1.0);
}
