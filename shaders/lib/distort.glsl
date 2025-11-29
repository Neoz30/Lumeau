#ifndef DISTORT
#define DISTORT

const bool shadowtex0Nearest = true;
const bool shadowtex1Nearest = true;
const bool shadowcolor0Nearest = true;

float f(vec2 v) {
	float sum = pow(abs(v.x), 8) + pow(abs(v.y), 8);
	return sqrt(sqrt(sqrt(sum)));
}

vec3 distortShadowClipPos(vec3 shadowClipPos) {
	float distortionFactor = 0.9 * f(shadowClipPos.xy) + 0.1;
	shadowClipPos.xy /= distortionFactor;
	shadowClipPos.z *= 0.5;
	return shadowClipPos;
}

#endif