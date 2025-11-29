#version 460 compatibility

uniform sampler2D texture;
uniform sampler2D lightmap;

in vec2 texcoord;
in vec2 lightcoord;
in vec4 glcolor;
in vec3 normal;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;

void main()
{
    color = glcolor * texture2D(texture, texcoord);
	color.rgb = pow(color.rgb, vec3(2.2));
	if (color.a < 0.01)
		discard ;
	lightmapData = vec4(lightcoord, 0.0, 1.0);
	encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);
}