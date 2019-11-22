import 'package:flutter_raytracing/ray_tracing/model/hit.dart';
import 'package:flutter_raytracing/ray_tracing/model/rgb.dart';
import 'package:flutter_raytracing/ray_tracing/textures/texture.dart';

class TextureCheck implements Texture {
  final RGB colour1;
  final RGB colour2;

  // Size of the blocks of color 1
  final double size;

  const TextureCheck()
      : this.colour1 = RGB.white,
        this.colour2 = RGB.black,
        this.size = 20.0;

  const TextureCheck.init(this.colour1, this.colour2, this.size);

  @override
  RGB getColourAt(Hit hit) {
    final h_size = size / 2.0;
    final xi = hit.intersection.x;
    final yi = hit.intersection.y;
    final zi = hit.intersection.z;

    //double xi = (hit.intersection.x < 0)? hit.intersection.x - h_size : hit.intersection.x;
    //double yi = (hit.intersection.y < 0)? hit.intersection.y - h_size : hit.intersection.y;
    //double zi = (hit.intersection.z < 0)? hit.intersection.z - h_size : hit.intersection.z;

    if ((yi % size).abs() < h_size) {
      if ((xi % size).abs() < h_size) {
        if ((zi % size).abs() < h_size) {
          return colour1;
        }
        return colour2;
      }
      else {
        if ((zi % size).abs() < h_size) {
          return colour2;
        }
        return colour1;
      }
    }
    else {
      if ((xi % size).abs() < h_size) {
        if ((zi % size).abs() < h_size) {
          return colour2;
        }
        return colour1;
      }
      else {
        if ((zi % size).abs() < h_size) {
          return colour1;
        }
        return colour2;
      }
    }
  }
}
