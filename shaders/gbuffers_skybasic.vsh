#version 460 compatibility

out vec4 glcolor;
out vec3 viewPos;

void main()
{
	viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    gl_Position = ftransform();
    glcolor = gl_Color;
}
