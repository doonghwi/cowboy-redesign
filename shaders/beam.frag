#version 460 core
#include <flutter/runtime_effect.glsl>

// Tracer beam bloom. Drawn into a horizontal strip rect; the caller rotates
// the canvas along the shooter->target line. The beam runs along the X axis,
// centered on Y, with a bright core, soft bloom, and a travelling muzzle head.
uniform vec2 uSize;     // strip size in pixels (length x thickness)
uniform vec4 uColor;    // beam colour (premultiplied at the end)
uniform float uProgress; // 0..1 — head travel + overall energy

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize; // 0..1
  float dy = abs(uv.y - 0.5) * 2.0;        // 0 at center, 1 at edges

  // Core line + wide bloom across the thickness.
  float core = smoothstep(0.16, 0.0, dy);
  float glow = smoothstep(1.0, 0.0, dy) * 0.55;

  // Travelling head: bright at the leading edge, fading tail behind it.
  float head = uProgress;
  float along = uv.x;
  float body = smoothstep(head, head - 0.85, along);       // tail falloff
  float spark = smoothstep(0.06, 0.0, abs(along - head));  // hot muzzle head
  float reveal = step(along, head + 0.02);                 // nothing ahead

  float energy = (core + glow) * body * reveal + spark * core;
  energy = clamp(energy, 0.0, 1.4);

  vec3 rgb = uColor.rgb + vec3(spark) * 0.6; // head whitens slightly
  float a = clamp(energy, 0.0, 1.0);
  fragColor = vec4(rgb * a, a);
}
