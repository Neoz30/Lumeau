#version 460 compatibility
#include "lib/utils.glsl"
#include "lib/lighting.glsl"
#include "settings.glsl"

uniform sampler2D colortex0;
uniform sampler2D depthtex0;

uniform float far;
uniform vec3 fogColor;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	color = texture2D(colortex0, texcoord);
	#if FOG
	float depth = texture2D(depthtex0, texcoord).r;
	if (depth == 1.0)
		return ;
	vec3 viewPos = projectAndDivide(gbufferProjectionInverse, vec3(texcoord, depth) * 2.0 - 1.0);
	color = mix(color, vec4(sunlightColor, 1.0), pow(length(viewPos) / far, 3));
	#endif
}