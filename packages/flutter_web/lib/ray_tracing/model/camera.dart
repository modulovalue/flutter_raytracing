import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import 'ray.dart';

class Camera {
  final Vector3 intersection;
  final Vector3 normal;
  final Ray Function(int width, int height, int x, int y) ray;

  const Camera({
    @required this.intersection,
    @required this.normal,
    @required this.ray,
  });
}