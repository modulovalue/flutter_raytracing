import 'package:image/image.dart';
import 'package:flutter_raytracing/ray_tracing/model/hit.dart';
import 'package:flutter_raytracing/ray_tracing/model/rgb.dart';
import 'package:flutter_raytracing/ray_tracing/textures/texture.dart';

class TextureImageUV implements Texture {
  static const int MODE_BILINEAR = 1;
  static const int MODE_NEAREST = 2;

  final double _scale_x;
  final double _scale_y;
  final int mode = MODE_NEAREST;
  final Image image;

  const TextureImageUV.init(this.image, this._scale_x, this._scale_y);

  @override
  RGB getColourAt(Hit hit) {
    final w = image.width.toDouble() * _scale_x;
    final h = image.height.toDouble() * _scale_y;
    final x = (hit.u * w) % image.width;
    final y = (hit.v * h) % image.height;
    final px = x.floor();
    final py = y.floor();

    switch (mode) {
      case 1:
        final px0 = px.clamp(0, image.width - 1).floor();
        final py0 = py.clamp(0, image.height - 1).floor();
        final px1 = (px + 1).clamp(0, image.width - 1).floor();
        final py1 = (py + 1).clamp(0, image.height - 1).floor();
        final p1 = _fromaabbggrr(image.getPixel(px0, py0));
        final p2 = _fromaabbggrr(image.getPixel(px1, py0));
        final p3 = _fromaabbggrr(image.getPixel(px0, py1));
        final p4 = _fromaabbggrr(image.getPixel(px1, py1));

        final fx = x - px;
        final fy = y - py;
        final fx1 = 1.0 - fx;
        final fy1 = 1.0 - fy;

        final w1 = fx1 * fy1;
        final w2 = fx * fy1;
        final w3 = fx1 * fy;
        final w4 = fx * fy;

        return RGB.init(
          p1.r * w1 + p2.r * w2 + p3.r * w3 + p4.r * w4,
          p1.g * w1 + p2.g * w2 + p3.g * w3 + p4.g * w4,
          p1.b * w1 + p2.b * w2 + p3.b * w3 + p4.b * w4,
          0.0,
        );
        break;
      case 2:
      default:
        return _fromaabbggrr(image.getPixel(px, py));
    }
  }
}

RGB _fromaabbggrr(int aabbggrr) {
  return RGB.init(
    ((aabbggrr & 0x000000ff) >> 0) / 255.0,
    ((aabbggrr & 0x0000ff00) >> 8) / 255.0,
    ((aabbggrr & 0x00ff0000) >> 16) / 255.0,
    (1 - ((aabbggrr & 0xff000000) >> 24)) / 255.0,
  );
}
