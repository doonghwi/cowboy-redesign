import 'dart:ui' as ui;

/// Loads and caches the fragment shaders used by the effect presenters.
/// Call [load] once (e.g. on lab/table screen init) before rendering effects.
/// A single shader instance is reused sequentially within a frame — each
/// painter sets its uniforms then draws synchronously, so there is no clash.
class EffectShaders {
  EffectShaders._();

  static ui.FragmentShader? beam;
  static ui.FragmentShader? ring;
  static bool get ready => beam != null && ring != null;

  static Future<void> load() async {
    if (ready) return;
    final beamProg = await ui.FragmentProgram.fromAsset('shaders/beam.frag');
    final ringProg = await ui.FragmentProgram.fromAsset('shaders/ring.frag');
    beam = beamProg.fragmentShader();
    ring = ringProg.fragmentShader();
  }
}
