import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'matrix.dart';

/// Core ray class, has point of orgin and direction vector
class Ray {
  Vector3 pos;
  Vector3 dir;
  int depth;

  /// Create a ray at the origin, pointing at origin. Useless, don't use this
  Ray() {
    pos = Vector3.zero();
    dir = Vector3.zero();
    depth = 1;
  }

  /// Create a ray at postion p1 with vector p2, normalised for safety
  Ray.init(double p1x, double p1y, double p1z, double p2x, double p2y,
      double p2z) {
    final v = Vector3(p2x, p2y, p2z);
    v.normalize();
    pos = Vector3(p1x, p1y, p1z);
    dir = v;
    depth = 1;
  }

  /// As above
  Ray.initPoint(Vector3 p, Vector3 d) {
    pos = Vector3(p.x, p.y, p.z);
    dir = Vector3(d.x, d.y, d.z);
    depth = 1;
  }

  /// Create a ray at point p1 aimed at p2, so that direction vector is calculated
  Ray.pointAt(Vector3 p1, Vector3 p2) {
    // ignore: prefer_initializing_formals
    pos = p1;
    dir = Vector3.zero();
    final temp = p2 - p1;
    dir.x = temp.x;
    dir.y = temp.y;
    dir.z = temp.z;
    dir.normalize();
    depth = 1;
  }

  /// Get point along ray t distance
  Vector3 getPoint(double t) {
    return Vector3(
      pos.x + (t * dir.x),
      pos.y + (t * dir.y),
      pos.z + (t * dir.z),
    );
  }

  void transform(TransMatrix tm) {
    tm.transformP(pos);
    tm.transformV(dir);
  }

  @override
  String toString() {
    return '$pos -> $dir';
  }
}