#version 460 compatibility
#include "/lib/utils.glsl"
#include "/lib/shadow.glsl"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;

uniform mat4 gbufferProjectionInverse;

uniform vec3 shadowLightPosition;
uniform vec3 camPosition;
uniform float sunAngle;

in vec2 texcoord;
in vec2 lightcoord;
in vec4 glcolor;
in vec3 normal;

in vec3 viewPos;

/* RENDERTARGETS: 0,1,2 */
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal;

const float pi = 3.1415927;

const vec3 blocklightColor = vec3(1.0, 0.5, 0.08);
const vec3 skylightColor = vec3(0.05, 0.15, 0.3);
const vec3 sunlightColor = vec3(0.99, 0.98, 0.83) * pow(vec3(0.95, 0.9, 0.8), vec3(2 * abs(tan(pi * sunAngle))));
const vec3 moonlightColor = vec3(0.05, 0.05, 0.44);
const vec3 ambientColor = vec3(0.1);

void main()
{
	float depth = texture2D(depthtex0, texcoord).r;
	color = glcolor * texture2D(colortex0, texcoord);
	color.rgb = pow(color.rgb, vec3(2.2));
	if (color.a < 0.01)
		discard ;
	lightmapData = vec4(lightcoord, 0.0, 1.0);
	encodedNormal = vec4(normal * 0.5 + 0.5, 1.0);

	vec2 lightmap = texture2D(colortex1, lightcoord).rg;
	vec3 shadow = getShadow(viewPos);

	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	vec3 blocklight = lightmap.r * blocklightColor;
	vec3 skylight = lightmap.g * skylightColor;
	vec3 ambient = ambientColor;
	vec3 sunlight = sunlightColor * clamp(dot(worldLightVector, normal), 0.0, 1.0) * shadow;

	vec3 specular = vec3(0.0);
	if (shadow != 0.0)
	{
		//vec3 viewPos = projectAndDivide(gbufferProjectionInverse, vec3(texcoord, depth) * 2.0 - 1.0);
		vec3 reflection = normalize(reflect(worldLightVector, normal));
		vec3 cam2px = normalize(mat3(gbufferModelViewInverse) * viewPos - camPosition);
		specular = vec3(pow(clamp(dot(reflection, cam2px), 0.0, 1.0), 16));
	}

	color.rgb *= ambient + sunlight + specular;
}