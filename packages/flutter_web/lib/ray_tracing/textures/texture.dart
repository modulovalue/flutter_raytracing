import 'package:flutter_raytracing/ray_tracing/model/hit.dart';
import 'package:flutter_raytracing/ray_tracing/model/rgb.dart';

abstract class Texture {
  RGB getColourAt(Hit h);
}
