#version 460 compatibility

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform vec3 cameraPosition;
uniform float frameTimeCounter;

in vec2 mc_Entity;

out vec2 texcoord;
out vec2 lightcoord;
out vec4 glcolor;
out vec3 normal;

void main()
{
	if (mc_Entity.x == 2)
	{
		vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
		pos = (gbufferModelViewInverse * vec4(pos, 1.0)).xyz;
		vec3 position = pos + cameraPosition;	

        pos.y += 0.1 * sin(position.x + position.z * 0.35 + frameTimeCounter);
    	gl_Position = gl_ProjectionMatrix * gbufferModelView * vec4(pos, 1.0);
	}
	else
		gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    lightcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    glcolor = gl_Color;
	normal = gl_Normal;
}
