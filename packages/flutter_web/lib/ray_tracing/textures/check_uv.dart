import 'package:flutter_raytracing/ray_tracing/model/hit.dart';
import 'package:flutter_raytracing/ray_tracing/model/rgb.dart';
import 'package:flutter_raytracing/ray_tracing/textures/texture.dart';

class TextureCheckUV implements Texture {
  final RGB colour1;
  final RGB colour2;
  // Size of the blocks of color 1
  final double size;

  const TextureCheckUV()
      : this.colour1 = RGB.white,
        this.colour2 =RGB.black,
        this.size = 1.0;

  const TextureCheckUV.init(this.colour1, this.colour2, this.size);

  @override
  RGB getColourAt(Hit hit) {
    final h_size = size / 2.0;

    if (hit.u % size < h_size) {
      if (hit.v % size < h_size) {
        return colour1;
      } else {
        return colour2;
      }
    } else {
      if (hit.v % size < h_size) {
        return colour2;
      } else {
        return colour1;
      }
    }
  }
}
