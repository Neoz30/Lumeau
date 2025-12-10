#version 460 compatibility
#include "/lib/distort.glsl"
#include "settings.glsl"

uniform mat4 shadowModelView;
uniform mat4 shadowModelViewInverse;
uniform vec3 cameraPosition;
uniform float frameTimeCounter;

in vec2 mc_Entity;

out vec2 texcoord;
out vec4 glcolor;

void main() {
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;

	vec3 pos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    pos = (shadowModelViewInverse * vec4(pos, 1.0)).xyz;
    vec3 position = pos + cameraPosition;

    if (mc_Entity.x == 1)
        pos.y += WAVE_AMPLITUDE * sin(position.x + 0.35 * position.z + frameTimeCounter);

    gl_Position = gl_ProjectionMatrix * shadowModelView * vec4(pos, 1.0);
	gl_Position.xyz = distortShadowClipPos(gl_Position.xyz);
}