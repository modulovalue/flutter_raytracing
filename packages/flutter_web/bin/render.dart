import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

// ignore: import_of_legacy_library_into_null_safe
import 'package:image/image.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

void main() {
  final scene = Render.makeScene((path) => File(path).readAsBytesSync());
  print("start");
  final img = Render.renderSceneToImage(scene, 700, 300);
  final pngImage = PngEncoder().encodeImage(img);
  File("out.png").writeAsBytesSync(pngImage);
  print("done");
}

class Render {
  static Image renderSceneToImage(Scene scene, int width, int height) {
    final camera = Camera(
      ray: (width, height, x, y) => Ray.pointAt(
        Vector3(0.0, 0.0, -1500.0),
        Vector3(x - width / 2, height / 2 - y, 0.0),
      ),
      intersection: Vector3.zero(),
      normal: Vector3.zero(),
    );
    return Image.fromBytes(
      width,
      height,
      () {
        final data = Uint8List(width * height * 4);
        final rowStride = width * 4;
        const rowStart = 0;
        final rowEnd = height;
        const colStart = 0;
        final colEnd = width;
        for (int row = rowStart; row < rowEnd; row++) {
          for (int col = colStart; col < colEnd; col++) {
            final int pos = row * rowStride + col * 4;
            final clr = scene.shadeRay(camera.ray(width, height, col, row), col, row);
            data.setRange(pos, pos + 4, [
              (clr.r * 255.0).clamp(0, 255).floor(),
              (clr.g * 255.0).clamp(0, 255).floor(),
              (clr.b * 255.0).clamp(0, 255).floor(),
              255 - (clr.a * 255.0).clamp(0, 255).floor(),
            ]);
          }
        }
        return data;
      }(),
    );
  }

  static Scene makeScene(Uint8List Function(String path) loadBytes) {
    final grass = decodeJpg(loadBytes("rt_assets/scenes/textures/grass.jpg"));
    final clouds = decodeJpg(loadBytes("rt_assets/scenes/textures/clouds.jpg"));
    final dartflutter = decodePng(loadBytes("rt_assets/scenes/textures/dartflutter.png"))!;
    return Scene(
      [
        Sphere(
          Vector3(60, 0, -850),
          50.0,
          const ObjectStyle(
            TextureColor.init(RGB.init(0.25, 0.582, 0.273, 0)),
            Material.init(1.0, 1.0, 1.0, 100, 0.4, false),
          ),
        ),
        Sphere(
          Vector3(-80.0, 0.0, -650),
          25.0,
          const ObjectStyle(
            TextureColor.init(RGB.black),
            Material.init(1.0, 1.0, 0.8, 50, 0.8, false),
          ),
        ),
        Plane(
          Vector3(0.0, 0.0, 0.0),
          Vector3(0.0, 1.0, -0.05),
          5000,
          5000,
          ObjectStyle(
            TextureImageUV.init(grass, 50, 100),
            const Material.init(1.0, 1.0, 1.0, 200.0, 0.1, false),
          ),
        ),
        Plane(
          Vector3(-70.0, 1000.0, -1500.0),
          Vector3(0, 0.1, 1),
          80 * 20.0,
          40 * 20.0,
          ObjectStyle(
            TextureImageUV.init(dartflutter, 1, -1),
            const Material.init(0.7, 1.0, 0.0, 20.0, 0.2, true),
          ),
        ),
        Plane(
          Vector3(0.0, 1000.0, 0.0),
          Vector3(0.0, 1.0, 0.02),
          9200,
          9200,
          ObjectStyle(
            TextureImageUV.init(clouds, 5, 10),
            const Material.init(1.0, 1.0, 0.0, 1.0, 0.0, true),
          ),
        ),
      ],
      Light(Vector3(0.0, 150.0, -1000)),
    );
  }
}

class Camera {
  final Vector3 intersection;
  final Vector3 normal;
  final Ray Function(int width, int height, int x, int y) ray;

  const Camera({
    required this.intersection,
    required this.normal,
    required this.ray,
  });
}

class Hit {
  final Vector3 intersection;
  final Vector3 normal;
  final Vector3 reflected;
  final double u;
  final double v;

  const Hit({
    required this.intersection,
    required this.normal,
    required this.reflected,
    this.u = 0.0,
    this.v = 0.0,
  });
}

class Light {
  final Vector3 pos;

  const Light(this.pos);

  Light.list(List<num> list) : this.pos = Vector3.array(list.map((a) => a.toDouble()).toList());
}

class Material {
  /// Ambient coefficient.
  final double ka;

  /// Diffuse component.
  final double kd;

  /// Specular component.
  final double ks;

  /// Reflectivity coefficient.
  final double kr;
  final double hardness;
  final bool no_shade;

  const Material.deflt()
      : ka = 0.7,
        kd = 0.8,
        ks = 0.9,
        hardness = 10.0,
        kr = 0.0,
        no_shade = false;

  const Material.init(this.ka, this.kd, this.ks, this.hardness, this.kr, this.no_shade);

  factory Material.list(List<num> ml) {
    return Material.init(
      ml[0].toDouble(),
      ml[1].toDouble(),
      ml[2].toDouble(),
      ml[3].toDouble(),
      ml[4].toDouble(),
      ml[5] == 1,
    );
  }
}

class TransMatrix {
  static const int X = 0;
  static const int Y = 1;
  static const int Z = 2;
  final _TwoDArray _mat;
  static const int SIZE = 4;
  static const double PI180 = pi / 180.0;

  TransMatrix() : _mat = _TwoDArray(SIZE);

  TransMatrix.identity() : _mat = _TwoDArray(SIZE) {
    for (int r = 0; r < _mat.size; r++) {
      for (int c = 0; c < _mat.size; c++) {
        if (r == c) {
          _mat.set(c, r, 1.0);
        }
      }
    }
  }

  TransMatrix.translate(Vector3 p) : _mat = _TwoDArray(SIZE) {
    for (int r = 0; r < _mat.size; r++) {
      for (int c = 0; c < _mat.size; c++) {
        if (r == c) {
          _mat.set(c, r, 1.0);
        }
      }
    }
    _mat.set(3, 0, p.x);
    _mat.set(3, 1, p.y);
    _mat.set(3, 2, p.z);
  }

  /// Create a rotation transform matrix; to rotate according to the X, Y & Z values of the tuple 's'
  TransMatrix.rotate(double x, double y, double z) : _mat = _TwoDArray(4) {
    final cosx = cos(toRadians(x));
    final sinx = sin(toRadians(x));
    final cosy = cos(toRadians(y));
    final siny = sin(toRadians(y));
    final cosz = cos(toRadians(z));
    final sinz = sin(toRadians(z));
    // Rotate about x axis
    this._mat.set(1, 1, cosx);
    this._mat.set(2, 2, cosx);
    this._mat.set(1, 2, sinx);
    this._mat.set(2, 1, 0.0 - sinx);
    TransMatrix temp_matrix = TransMatrix.identity();
    // Rotate about y axis
    temp_matrix._mat.set(0, 0, cosy);
    temp_matrix._mat.set(2, 2, cosy);
    temp_matrix._mat.set(0, 2, 0.0 - siny);
    temp_matrix._mat.set(2, 0, siny);
    this.multiply(temp_matrix);
    temp_matrix = TransMatrix.identity();
    // Rotate about z axis
    temp_matrix._mat.set(0, 0, cosz);
    temp_matrix._mat.set(1, 1, cosz);
    temp_matrix._mat.set(0, 1, sinz);
    temp_matrix._mat.set(1, 0, 0.0 - sinz);
    this.multiply(temp_matrix);
  }

  double toRadians(double d) => d * PI180;

  void transformP(Vector3 p) {
    p.x = p.x * _mat.get(0, 0) + p.y * _mat.get(1, 0) + p.z * _mat.get(2, 0) + 1 * _mat.get(3, 0);
    p.y = p.x * _mat.get(0, 1) + p.y * _mat.get(1, 1) + p.z * _mat.get(2, 1) + 1 * _mat.get(3, 1);
    p.z = p.x * _mat.get(0, 2) + p.y * _mat.get(1, 2) + p.z * _mat.get(2, 2) + 1 * _mat.get(3, 2);
  }

  void transformV(Vector3 p) {
    p.x = p.x * _mat.get(0, 0) + p.y * _mat.get(1, 0) + p.z * _mat.get(2, 0);
    p.y = p.x * _mat.get(0, 1) + p.y * _mat.get(1, 1) + p.z * _mat.get(2, 1);
    p.z = p.x * _mat.get(0, 2) + p.y * _mat.get(1, 2) + p.z * _mat.get(2, 2);
  }

  void multiply(TransMatrix tm) {
    final temp_matrix = TransMatrix();
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        for (int k = 0; k < 3; k++) {
          double val = temp_matrix._mat.get(i, j);
          temp_matrix._mat.set(i, j, val += this._mat.get(i, k) * tm._mat.get(k, j));
        }
      }
    }
    for (int i = 0; i < SIZE; i++) {
      for (int j = 0; j < SIZE; j++) {
        this._mat.set(i, j, temp_matrix._mat.get(i, j));
      }
    }
  }
}

class _TwoDArray {
  final List<double> _data;

  final int size;

  _TwoDArray(this.size) : _data = List.filled(size * size, 0.0);

  double get(int c, int r) => _data[r * size + c];

  void set(int c, int r, double val) => _data[r * size + c] = val;
}

/// Core ray class, has point of orgin and direction vector
class Ray {
  final Vector3 pos;
  final Vector3 dir;
  int depth;

  /// Create a ray at the origin, pointing at origin. Useless, don't use this
  Ray()
      : pos = Vector3.zero(),
        dir = Vector3.zero(),
        depth = 1;

  /// Create a ray at postion p1 with vector p2, normalised for safety
  Ray.init(double p1x, double p1y, double p1z, double p2x, double p2y, double p2z)
      : pos = Vector3(p1x, p1y, p1z),
        dir = Vector3(p2x, p2y, p2z)..normalize(),
        depth = 1;

  /// As above
  Ray.initPoint(Vector3 p, Vector3 d)
      : pos = Vector3(p.x, p.y, p.z),
        dir = Vector3(d.x, d.y, d.z),
        depth = 1;

  /// Create a ray at point p1 aimed at p2, so that direction vector is calculated
  Ray.pointAt(this.pos, Vector3 p2)
      : dir = (p2 - pos)..normalize(),
        depth = 1;

  /// Get point along ray t distance
  Vector3 getPoint(double t) => Vector3(
        pos.x + (t * dir.x),
        pos.y + (t * dir.y),
        pos.z + (t * dir.z),
      );

  void transform(TransMatrix tm) {
    tm.transformP(pos);
    tm.transformV(dir);
  }

  @override
  String toString() {
    return '$pos -> $dir';
  }
}

/// Colour held as a RGBA tuple
/// Range 0.0 - 1.0. Alpha is transparency 0.0 = opaque, 1.0 = fully transparent
class RGB {
  static const RGB black = RGB.init(0.0, 0.0, 0.0, 0.0);
  static const RGB white = RGB.init(1.0, 1.0, 1.0, 0.0);
  static const RGB red = RGB.init(1.0, 0.0, 0.0, 0.0);

  final double r;
  final double g;
  final double b;
  final double a;

  const RGB.zero()
      : this.r = 0.0,
        this.g = 0.0,
        this.b = 0.0,
        this.a = 0.0;

  const RGB.init(this.r, this.g, this.b, this.a);

  factory RGB.list(List<num> cl) {
    return RGB.init(
      cl[0].toDouble(),
      cl[1].toDouble(),
      cl[2].toDouble(),
      cl[3].toDouble(),
    );
  }

  RGB blendF(num f) => RGB.init(r * (1.0 - f) + f, g * (1.0 - f) + f, b * (1.0 - f) + f, a);

  RGB scaleF(double f) => RGB.init(r * f, g * f, b * f, a);

  RGB addF(RGB colour) => RGB.init(r + colour.r, g + colour.g, b + colour.b, a);

  RGB scaleRGBF(RGB color) => RGB.init(r * color.r, g * color.g, b * color.b, a);

  RGB addSomeF(RGB color, double amount) => RGB.init(
        r + color.r * amount,
        g + color.g * amount,
        b + color.b * amount,
        a,
      );

  @override
  String toString() => "[$r, $g, $b, $a]";
}

/// Holds all objects, lights, camera etc plus global details
class Scene {
  final List<Object3D> objs;
  final Light light;

  int get maxdepth => 2;

  const Scene(this.objs, this.light);

  RGB shadeRay(Ray ray, int x, int y) => shadeRayForScene(this, ray, x, y);

  @override
  String toString() => 'Scene{_objs: $objs, lights: $light, maxdepth: $maxdepth}';
}

RGB shadeRayForScene(Scene scene, Ray ray, int x, int y) {
  double t = double.infinity;
  late Object3D hitObj;
  for (final obj in scene.objs) {
    final newT = obj.calcT(ray);
    if (newT > 0.0 && newT < t) {
      t = newT;
      hitObj = obj;
    }
  }
  final objectWasHit = t > 0.0 && t < double.infinity;
  if (objectWasHit) {
    final hit = hitObj.calcHitDetails(t, ray);
    final light = scene.light.pos;
    final lv = light - hit.intersection;
    final lightDist = lv.length;
    lv.normalize();
    RGB hitColor = hitObj.style.texture.getColourAt(hit);
    // Shadow test
    final shadow = Ray.initPoint(hit.intersection, lv);
    double shadowT = double.infinity;
    bool inshadow = false;
    for (final Object3D obj in scene.objs) {
      final newT = obj.calcT(shadow);
      if (newT > 0.0 && newT < shadowT && newT < lightDist) {
        shadowT = newT;
        break;
      }
    }
    if (shadowT > 0.0 && shadowT < double.infinity) {
      inshadow = true;
    }
    final doLightingCalculation = !inshadow;
    if (doLightingCalculation) {
      final diffuseLightingIntensity = max(0.01, lv.dot(hit.normal));
      //* (800000 / (light_dist * light_dist) )
      //intens = intens * (800000 / (light_dist * light_dist) );
      if (hitObj.style.material.no_shade == true) {
        hitColor = hitColor.scaleF(1.0);
      } else {
        hitColor = hitColor.scaleF(diffuseLightingIntensity);
      }
      final angleBetweenLightAndReflRay = max(0.0, hit.reflected.dot(lv));
      final phongSpecularTerm = pow(
            angleBetweenLightAndReflRay,
            hitObj.style.material.hardness,
          ) *
          hitObj.style.material.ks;
      hitColor = hitColor.blendF(phongSpecularTerm);
    } else {
      hitColor = hitColor.scaleF(0.15);
    }
    if (ray.depth < scene.maxdepth) {
      if (hitObj.style.material.kr > 0.0) {
        final reflectRay = Ray.initPoint(hit.intersection, hit.reflected);
        reflectRay.depth = ray.depth + 1;
        RGB reflectColor = shadeRayForScene(scene, reflectRay, x, y);
        reflectColor = reflectColor.scaleF(hitObj.style.material.kr);
        hitColor = hitColor.addF(reflectColor);
      }
    }
    return hitColor;
  } else {
    final missedAllObjects = ray.depth == 1;
    if (missedAllObjects) {
      // TODO draw background
      return RGB.black;
    } else {
      return RGB.black;
    }
  }
}

abstract class Object3D {
  static const double THRES = 0.001;

  Vector3 get position;

  ObjectStyle get style;

  bool get rayinside;

  Ray get objectSpaceRay;

  double calcT(Ray r);

  Hit calcHitDetails(double t, Ray ray);

  TransMatrix forward() => TransMatrix.translate(position);

  TransMatrix reverse_transform() => TransMatrix.translate(position.clone()..negate());
}

class ObjectStyle {
  final Texture texture;
  final Material material;

  const ObjectStyle(this.texture, this.material);

  const ObjectStyle.normal()
      : texture = const TextureColor(),
        material = const Material.deflt();
}

class Plane extends Object3D {
  @override
  final ObjectStyle style;

  @override
  late Ray objectSpaceRay;

  @override
  Vector3 position = Vector3.zero();

  @override
  bool rayinside = false;

  final Vector3 _normal;
  final Vector3 _normal_reverse;
  late double _vd;
  final double _width;
  final double _height;
  late double u, v;

  Plane(this.position, Vector3 direction, this._width, this._height, this.style)
      : _normal = Vector3(direction.x, direction.y, direction.z)..normalize(),
        _normal_reverse = Vector3(direction.x, direction.y, direction.z)
          ..normalize()
          ..negate();

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
    } else {
      final intersection_object = objectSpaceRay.getPoint(t);
      if (intersection_object.x > _width || intersection_object.x < -_width) {
        return 0.0;
      } else {
        if (intersection_object.y > _height || intersection_object.y < -_height) {
          return 0.0;
        } else {
          u = (intersection_object.x + _width) / (_width * 2);
          v = (intersection_object.y + _height) / (_height * 2);
          return t;
        }
      }
    }
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

class Sphere extends Object3D {
  @override
  final ObjectStyle style;

  @override
  late Ray objectSpaceRay;

  @override
  Vector3 position = Vector3.zero();

  @override
  bool rayinside = false;

  final double _r2;

  Sphere(this.position, double _r, this.style) : _r2 = _r * _r;

  @override
  double calcT(Ray inputRay) {
    // Copy the input ray and transform to object space
    objectSpaceRay = Ray.initPoint(inputRay.pos, inputRay.dir)..transform(reverse_transform());
    final b = 2.0 * objectSpaceRay.pos.dot(objectSpaceRay.dir);
    final c = objectSpaceRay.pos.dot(objectSpaceRay.pos) - _r2;
    double d = b * b - 4.0 * c;
    // miss
    if (d <= 0.0) {
      return 0.0;
    } else {
      d = sqrt(d);
      final t1 = (-b + d) / 2.0;
      final t2 = (-b - d) / 2.0;
      if (t1.abs() < Object3D.THRES || t2.abs() < Object3D.THRES) {
        return 0.0;
      } else {
        // Ray is inside if there is only 1 positive root
        // Added for refractive transparency
        if (t1 < 0 && t2 > 0) {
          rayinside = true;
          return t2;
        } else if (t2 < 0 && t1 > 0) {
          rayinside = true;
          return t1;
        } else {
          return (t1 < t2) ? t1 : t2;
        }
      }
    }
  }

  @override
  Hit calcHitDetails(double t, Ray ray) {
    // Normal on a sphere is really easy in object space
    final inter_object_space = objectSpaceRay.getPoint(t);
    final normal = inter_object_space.clone()..normalize();
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

abstract class Texture {
  RGB getColourAt(Hit h);
}

class TextureCheck implements Texture {
  final RGB colour1;
  final RGB colour2;
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
    // double xi = (hit.intersection.x < 0)? hit.intersection.x - h_size : hit.intersection.x;
    // double yi = (hit.intersection.y < 0)? hit.intersection.y - h_size : hit.intersection.y;
    // double zi = (hit.intersection.z < 0)? hit.intersection.z - h_size : hit.intersection.z;
    if ((yi % size).abs() < h_size) {
      if ((xi % size).abs() < h_size) {
        if ((zi % size).abs() < h_size) {
          return colour1;
        } else {
          return colour2;
        }
      } else {
        if ((zi % size).abs() < h_size) {
          return colour2;
        } else {
          return colour1;
        }
      }
    } else {
      if ((xi % size).abs() < h_size) {
        if ((zi % size).abs() < h_size) {
          return colour2;
        } else {
          return colour1;
        }
      } else {
        if ((zi % size).abs() < h_size) {
          return colour1;
        } else {
          return colour2;
        }
      }
    }
  }
}

class TextureCheckUV implements Texture {
  final RGB colour1;
  final RGB colour2;

  // Size of the blocks of color 1
  final double size;

  const TextureCheckUV()
      : this.colour1 = RGB.white,
        this.colour2 = RGB.black,
        this.size = 1.0;

  const TextureCheckUV.init(this.colour1, this.colour2, this.size);

  @override
  RGB getColourAt(Hit hit) {
    final h_size = size / 2.0;
    if (hit.u % size < h_size) {
      if (hit.v % size < h_size) {
        return colour1;
      } else {
        return colour2;
      }
    } else {
      if (hit.v % size < h_size) {
        return colour2;
      } else {
        return colour1;
      }
    }
  }
}

class TextureColor implements Texture {
  final RGB color;

  const TextureColor() : this.color = RGB.white;

  const TextureColor.init(this.color);

  @override
  RGB getColourAt(Hit h) => this.color;
}

class TextureImageUV implements Texture {
  static const int MODE_BILINEAR = 1;
  static const int MODE_NEAREST = 2;
  final double _scale_x;
  final double _scale_y;
  final Image image;

  int get mode => MODE_NEAREST;

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
      case 2:
      default:
        return _fromaabbggrr(image.getPixel(px, py));
    }
  }
}

RGB _fromaabbggrr(int aabbggrr) => RGB.init(
      ((aabbggrr & 0x000000ff) >> 0) / 255.0,
      ((aabbggrr & 0x0000ff00) >> 8) / 255.0,
      ((aabbggrr & 0x00ff0000) >> 16) / 255.0,
      (1 - ((aabbggrr & 0xff000000) >> 24)) / 255.0,
    );
