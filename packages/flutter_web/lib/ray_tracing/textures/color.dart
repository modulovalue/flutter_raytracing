import 'package:flutter_raytracing/ray_tracing/model/hit.dart';
import 'package:flutter_raytracing/ray_tracing/model/rgb.dart';
import 'package:flutter_raytracing/ray_tracing/textures/texture.dart';

class TextureColor implements Texture {
  final RGB color;

  const TextureColor() : this.color = RGB.white;

  const TextureColor.init(this.color);

  @override
  RGB getColourAt(Hit h) => this.color;
}
