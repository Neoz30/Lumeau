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

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

const float pi = 3.1415927;

const vec3 blocklightColor = vec3(1.0, 0.5, 0.08);
const vec3 skylightColor = vec3(0.05, 0.15, 0.3);
const vec3 sunlightColor = vec3(0.99, 0.98, 0.83);
const vec3 moonlightColor = vec3(0.05, 0.05, 0.44);
const vec3 ambientColor = vec3(0.1);

void main()
{
	float depth = texture2D(depthtex0, texcoord).r;
	color = texture2D(colortex0, texcoord);
	color.rgb = pow(color.rgb, vec3(2.2));
	if (depth == 1.0)
		return ;
	vec2 lightmap = texture2D(colortex1, texcoord).rg;
	vec3 normal = normalize((texture(colortex2, texcoord).rgb - 0.5) * 2.0);

	vec3 shadow = getShadow(projectAndDivide(gbufferProjectionInverse, vec3(texcoord, depth) * 2.0 - 1.0));

	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector;

	vec3 blocklight = lightmap.r * blocklightColor;
	vec3 skylight = lightmap.g * skylightColor;
	vec3 ambient = ambientColor * sunlightColor;
	vec3 sunlight = mix(sunlightColor, moonlightColor, smoothstep(0.0, 1.0, sunAngle)) * clamp(dot(worldLightVector, normal), 0.0, 1.0) * lightmap.g * shadow;

	vec3 specular = vec3(0.0);
	if (shadow != 0.0)
	{
		vec3 viewPos = projectAndDivide(gbufferProjectionInverse, vec3(texcoord, depth) * 2.0 - 1.0);
		vec3 reflection = normalize(reflect(worldLightVector, normal));
		vec3 cam2px = normalize(mat3(gbufferModelViewInverse) * viewPos - camPosition);
		specular = vec3(pow(clamp(dot(reflection, cam2px), 0.0, 1.0), 16)) * mix(sunlightColor, moonlightColor, smoothstep(0.0, 1.0, sunAngle));
	}

	color.rgb *= blocklight + skylight + ambient + sunlight + specular;
}
