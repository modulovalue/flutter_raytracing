import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class Hit {
  final Vector3 intersection;
  final Vector3 normal;
  final Vector3 reflected;
  final double u;
  final double v;

  const Hit({
    @required this.intersection,
    @required this.normal,
    @required this.reflected,
    this.u = 0.0,
    this.v = 0.0,
  });
}