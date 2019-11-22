import 'package:flutter_raytracing/ray_tracing/model/hit.dart';
import 'package:flutter_raytracing/ray_tracing/model/ray.dart';
import 'package:flutter_raytracing/ray_tracing/objects/object_3d.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class Plane extends Object3D {
  @override
  final ObjectStyle style;

  @override
  Ray objectSpaceRay;

  @override
  Vector3 position = Vector3.zero();

  @override
  bool rayinside = false;

  Vector3 _normal;
  Vector3 _normal_reverse;
  double _vd;
  final double _width;
  final double _height;
  double u, v;

  Plane(this.position, Vector3 direction, this._width, this._height,
      this.style) {
    _normal = Vector3(direction.x, direction.y, direction.z);
    _normal_reverse = Vector3(direction.x, direction.y, direction.z);
    _normal.normalize();
    _normal_reverse.normalize();
    _normal_reverse.negate();
  }

  @override
  double calcT(Ray ray) {
    objectSpaceRay = Ray.initPoint(ray.pos, ray.dir);
    objectSpaceRay.transform(reverse_transform());

    // When ray -> P + tV = 0
    // t = -(N dot P + D) / (N dot V)
    // vo = -(N dot P + D) and vd = (N dot V)
    _vd = objectSpaceRay.dir.dot(_normal);
    if (_vd == 0.0) return 0.0;
    final vo = -_normal.dot(objectSpaceRay.pos);

    final t = vo / _vd;
    if (t.abs() < Object3D.THRES) {
      return 0.0;
    }

    final intersection_object = objectSpaceRay.getPoint(t);
    if (intersection_object.x > _width || intersection_object.x < -_width) {
      return 0.0;
    }
    if (intersection_object.y > _height || intersection_object.y < -_height) {
      return 0.0;
    }
    u = (intersection_object.x + _width) / (_width * 2);
    v = (intersection_object.y + _height) / (_height * 2);

    return t;
  }

  @override
  Hit calcHitDetails(double t, Ray inray) {
    final normal = _vd < 0.0 ? _normal : _normal_reverse;

    //_reverse.transNormal(norm);
    //norm.normalise();

    final r = Vector3.zero();
    final k = -inray.dir.dot(normal);
    r.x = inray.dir.x + 2 * normal.x * k;
    r.y = inray.dir.y + 2 * normal.y * k;
    r.z = inray.dir.z + 2 * normal.z * k;
    r.normalize();

    final hit = Hit(
      intersection: inray.getPoint(t),
      normal: normal,
      reflected: r,
      u: u,
      v: v,
    );

    return hit;
  }

}
