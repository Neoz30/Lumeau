#ifndef SHADOW
#define SHADOW

#include "utils.glsl"
#include "distort.glsl"

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

const mat4 viewToClip = shadowProjection * shadowModelView * gbufferModelViewInverse;

vec3 getShadow(vec3 viewPos) {
	vec4 shadowClipPos = viewToClip * vec4(viewPos, 1.0);
	shadowClipPos.z -= 1e-3;
	shadowClipPos.xyz = distortShadowClipPos(shadowClipPos.xyz);
	vec3 shadowScreenPos = (shadowClipPos.xyz / shadowClipPos.w) * 0.5 + 0.5;

	float transparentShadow = step(shadowScreenPos.z, texture2D(shadowtex0, shadowScreenPos.xy).r);
	if(transparentShadow == 1.0)
		return vec3(1.0);

	float opaqueShadow = step(shadowScreenPos.z, texture2D(shadowtex1, shadowScreenPos.xy).r);
	if(opaqueShadow == 0.0)
		return vec3(0.0);

	vec4 shadowColor = texture2D(shadowcolor0, shadowScreenPos.xy);
	return shadowColor.rgb * (1.0 - shadowColor.a);
}

#endif