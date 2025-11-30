#version 460 compatibility
#include "/lib/utils.glsl"
#include "/lib/shadow.glsl"
#include "/lib/lighting.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D depthtex0;

in vec2 texcoord;
in vec2 lightcoord;
in vec4 glcolor;
in vec3 normal;

in vec3 viewPos;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;

void main()
{
	color = glcolor * texture2D(colortex0, texcoord);
	color.rgb = pow(color.rgb, vec3(2.2));
	if (color.a < 0.01)
		discard ;
	lightmapData = vec4(lightcoord, 0.0, 1.0);
	encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);

	vec3 shadow = getShadow(viewPos);

	color.rgb *= phongLightColor(viewPos, normal, shadow) + blockLightColor(lightcoord.r);
}