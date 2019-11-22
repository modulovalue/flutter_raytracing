import 'dart:math';

import 'package:flutter_raytracing/ray_tracing/model/hit.dart';
import 'package:flutter_raytracing/ray_tracing/model/ray.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import 'object_3d.dart';

class Sphere extends Object3D {
  @override
  final ObjectStyle style;

  @override
  Ray objectSpaceRay;

  @override
  Vector3 position = Vector3.zero();

  @override
  bool rayinside = false;

  double _r2;
  final double _r;

  Sphere(this.position, this._r, this.style) {
    _r2 = _r * _r;
  }

  @override
  double calcT(Ray inputRay) {
    // Copy the input ray and transform to object space
    objectSpaceRay = Ray.initPoint(inputRay.pos, inputRay.dir)
      ..transform(reverse_transform());

    final b = 2.0 * objectSpaceRay.pos.dot(objectSpaceRay.dir);
    final c = objectSpaceRay.pos.dot(objectSpaceRay.pos) - _r2;

    double d = b * b - 4.0 * c;

    // miss
    if (d <= 0.0) {
      return 0.0;
    }

    d = sqrt(d);
    final t1 = (-b + d) / 2.0;
    final t2 = (-b - d) / 2.0;

    if (t1.abs() < Object3D.THRES || t2.abs() < Object3D.THRES) {
      return 0.0;
    }

    // Ray is inside if there is only 1 positive root
    // Added for refractive transparency
    if (t1 < 0 && t2 > 0) {
      rayinside = true;
      return t2;
    }

    if (t2 < 0 && t1 > 0) {
      rayinside = true;
      return t1;
    }

    return (t1 < t2) ? t1 : t2;
  }

  @override
  Hit calcHitDetails(double t, Ray ray) {
    // Normal on a sphere is really easy in object space
    final inter_object_space = objectSpaceRay.getPoint(t);
    final normal = inter_object_space.clone()
      ..normalize();
    final intersection = ray.getPoint(t);

    final hit = Hit(
      // Calc hit point in world space
      intersection: intersection,
      normal: normal,
      u: 0.0,
      v: 0.0,
      // Reflected ray
      reflected: ray.dir.reflected(normal),
    );
    return hit;
  }
}