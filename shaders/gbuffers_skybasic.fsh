#version 460 compatibility
#include "lib/lighting.glsl"

uniform int renderStage;

in vec3 viewPos;
in vec4 glcolor;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

float cubed(float a)
{
	return (clamp(a * 1.25, 0.0, 1.0));
}

void main()
{
	if (renderStage == MC_RENDER_STAGE_STARS)
	{
		color = glcolor;
		return ;
	}
	color = mix(vec4(skylightColor, 1.0), vec4(sunlightColor, 1.0), clamp(dot(normalize(viewPos), shadowLightPosition * 0.01), 0.0, 1.0));
}
