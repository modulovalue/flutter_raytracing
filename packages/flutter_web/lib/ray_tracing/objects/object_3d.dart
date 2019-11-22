import 'package:flutter_raytracing/ray_tracing/model/hit.dart';
import 'package:flutter_raytracing/ray_tracing/model/material.dart';
import 'package:flutter_raytracing/ray_tracing/model/matrix.dart';
import 'package:flutter_raytracing/ray_tracing/model/ray.dart';
import 'package:flutter_raytracing/ray_tracing/textures/color.dart';
import 'package:flutter_raytracing/ray_tracing/textures/texture.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

/// Abstract class for all objects
abstract class Object3D {
  static const double THRES = 0.001;

  /// Position of the object
  Vector3 get position;

  ObjectStyle get style;

  bool get rayinside;

  Ray get objectSpaceRay;

  TransMatrix forward() => TransMatrix.translate(position);

  TransMatrix reverse_transform() =>
      TransMatrix.translate(position.clone()
        ..negate());

  double calcT(Ray r);

  Hit calcHitDetails(double t, Ray ray);
}

class ObjectStyle {
  final Texture texture;

  final Material material;

  const ObjectStyle(this.texture, this.material);

  const ObjectStyle.normal()
      : texture = const TextureColor(),
        material = const Material.deflt();
}