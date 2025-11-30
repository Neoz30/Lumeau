#ifndef UTILS
#define UTILS

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform mat4 gbufferProjectionInverse;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
	vec4 homPos = projectionMatrix * vec4(position, 1.0);
	return homPos.xyz / homPos.w;
}

#endif