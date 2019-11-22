import 'package:vector_math/vector_math_64.dart' show Vector3;

class Light {
  final Vector3 pos;

  const Light(this.pos);

  Light.list(List<num> list)
      : this.pos = Vector3.array(list.map((a) => a.toDouble()).toList());
}