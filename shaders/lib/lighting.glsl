#ifndef LIGHTING
#define LIGHTING
#include "utils.glsl"

uniform vec3 shadowLightPosition;
uniform vec3 camPosition;
uniform float sunAngle;

const float ambientStrength = 0.1;
const float diffuseStrength = 0.8;
const float specularStrength = 1.0;
const float shininess = 16.0;
const vec3 worldLightVector = mat3(gbufferModelViewInverse) * (0.01 * shadowLightPosition);

const float tau = 6.2831853;
const float sint = clamp(sin(tau * sunAngle), 0.0, 1.0);
const float dist = 1.0 / sint;
const vec3 sunlightColor = pow(vec3(0.95, 0.9, 0.8), vec3(dist));
const vec3 skylightColor = vec3(1.0, 2.0, 4.0) * sint;
const vec3 blocklightColor = vec3(1.0, 0.5, 0.08);

vec3 phongLightColor(vec3 viewPos, vec3 normal, vec3 shadowColor)
{
	vec3 ambient = skylightColor;
	vec3 diffuse = clamp(dot(worldLightVector, normal), 0.0, 1.0) * sunlightColor;
	if (shadowColor == 0.0)
		return ambientStrength * ambient + diffuseStrength * diffuse;
	vec3 reflection = normalize(reflect(worldLightVector, normal));
	vec3 cam2px = normalize(mat3(gbufferModelViewInverse) * viewPos - camPosition);
	vec3 specular = vec3(pow(clamp(dot(reflection, cam2px), 0.0, 1.0), shininess)) * sunlightColor;
	return ambientStrength * ambient + diffuseStrength * diffuse + specularStrength * specular;
}

vec3 blockLightColor(float brightness)
{
	return brightness * blocklightColor;
}

#endif