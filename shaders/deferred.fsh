#version 460 compatibility
#include "/lib/distort.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform vec3 shadowLightPosition;
uniform vec3 camPosition;

in vec2 texcoord;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

const vec3 blocklightColor = vec3(1.0, 0.5, 0.08);
const vec3 skylightColor = vec3(0.05, 0.15, 0.3);
const vec3 sunlightColor = vec3(0.99, 0.98, 0.83);
const vec3 moonlightColor = vec3(0.05, 0.05, 0.44);
const vec3 ambientColor = vec3(0.1);

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}

vec3 getShadow(vec3 screenPos) {
	vec4 shadowClipPos = shadowProjection * vec4(
		(shadowModelView * vec4(
			(gbufferModelViewInverse * vec4(
				projectAndDivide(gbufferProjectionInverse, screenPos * 2.0 - 1.0),
				1.0
			)).xyz,
			1.0
		)).xyz,
		1.0
	);
	shadowClipPos.z -= 1e-3;
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

void main() {
	float depth = texture2D(depthtex0, texcoord).r;
	color = texture2D(colortex0, texcoord);
	color.rgb = pow(color.rgb, vec3(2.2));
	if (depth == 1.0)
		return ;
	vec2 lightmap = texture2D(colortex1, texcoord).rg;
	vec3 normal = normalize((texture(colortex2, texcoord).rgb - 0.5) * 2.0);

	vec3 shadow = getShadow(vec3(texcoord, depth));

	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	vec3 blocklight = lightmap.r * blocklightColor;
	vec3 skylight = lightmap.g * skylightColor;
	vec3 ambient = ambientColor;
	vec3 sunlight = sunlightColor * clamp(dot(worldLightVector, normal), 0.0, 1.0) * lightmap.g * shadow;

	vec3 specular = vec3(0.0);
	if (shadow != 0.0)
	{
		vec3 viewPos = projectAndDivide(gbufferModelViewInverse, vec3(texcoord, depth));
		vec3 reflection = normalize(reflect(worldLightVector, normal));
		vec3 cam2px = normalize(mat3(gbufferModelViewInverse) * viewPos - camPosition);
		specular = vec3(pow(clamp(dot(reflection, cam2px), 0.0, 1.0), 16));
	}

	color.rgb *= blocklight + skylight + ambient + sunlight + specular;
}