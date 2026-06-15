#version 460 core
#include <flutter/runtime_effect.glsl>

// Shield / trap ring. Drawn into a square rect centered on a seat. A glowing
// annulus that pops outward; uProgress 0..1 grows the radius and fades the
// edge, giving a refractive shockwave feel.
uniform vec2 uSize;      // square size in pixels
uniform vec4 uColor;     // ring colour
uniform float uProgress; // 0..1 pop animation

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec2 p = (uv - 0.5) * 2.0;     // -1..1
  float r = length(p);           // 0 center, 1 edge

  // Ring radius eases out toward the rim as it pops.
  float ringR = mix(0.45, 0.92, uProgress);
  float d = abs(r - ringR);

  // Crisp ring + outer bloom.
  float ring = smoothstep(0.10, 0.0, d);
  float bloom = smoothstep(0.34, 0.0, d) * 0.4;

  // Energy peaks mid-pop, fades at the end.
  float life = sin(clamp(uProgress, 0.0, 1.0) * 3.14159);
  float a = clamp((ring + bloom) * life, 0.0, 1.0);

  fragColor = vec4(uColor.rgb * a, a);
}
