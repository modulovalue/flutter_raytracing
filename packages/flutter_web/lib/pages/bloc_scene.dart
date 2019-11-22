import 'package:bird/base.dart';
import 'package:bird/bird.dart';
import 'package:flutter_raytracing/ray_tracing/model/light.dart';
import 'package:flutter_raytracing/ray_tracing/model/material.dart';
import 'package:flutter_raytracing/ray_tracing/model/rgb.dart';
import 'package:flutter_raytracing/ray_tracing/model/scene.dart';
import 'package:flutter_raytracing/ray_tracing/objects/object_3d.dart';
import 'package:flutter_raytracing/ray_tracing/objects/plane.dart';
import 'package:flutter_raytracing/ray_tracing/objects/sphere.dart';
import 'package:flutter_raytracing/ray_tracing/textures/color.dart';
import 'package:flutter_raytracing/ray_tracing/textures/image_uv.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

import '../flutter_image.dart';

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: type_annotate_public_apis
class SceneBloc extends HookBloc {
  final _allImages = <String, FlutterImage>{}.$;
  final scene = none<Scene>().$;
  final isLoadingImages = true.$;

  SceneBloc() {
    loadImages().then((_) {
      isLoadingImages.add(false);
      loadDemoScene();
    });
  }

  void loadDemoScene() {
    this.scene.add(some(Scene(
      [
        Sphere(Vector3(60, 0, -850), 50.0, const ObjectStyle(
          TextureColor.init(RGB.init(0.25, 0.582, 0.273, 0)),
          Material.init(1.0, 1.0, 1.0, 100, 0.4, false),
        )),
        Sphere(Vector3(-80.0, 0.0, -650), 25.0, const ObjectStyle(
          TextureColor.init(RGB.black),
          Material.init(1.0, 1.0, 0.8, 50, 0.8, false),
        )),
        Plane(
          Vector3(0.0, 0.0, 0.0),
          Vector3(0.0, 1.0, -0.05),
          5000,
          5000,
          ObjectStyle(
            TextureImageUV.init(_allImages.value["grass"].imgImage, 50, 100),
            const Material.init(1.0, 1.0, 1.0, 200.0, 0.1, false),

          ),
        ),
        Plane(
          Vector3(-70.0, 1000.0, -1500.0),
          Vector3(0, 0.1, 1),
          80 * 20.0,
          40 * 20.0,
          ObjectStyle(
            TextureImageUV.init(_allImages.value["dart"].imgImage, 1, -1),
            const Material.init(0.7, 1.0, 0.0, 20.0, 0.2, true),

          ),
        ),
        Plane(
          Vector3(0.0, 1000.0, 0.0),
          Vector3(0.0, 1.0, 0.02),
          9200,
          9200,
          ObjectStyle(
            TextureImageUV.init(_allImages.value["clouds"].imgImage, 5, 10),
            const Material.init(1.0, 1.0, 0.0, 1.0, 0.0, true),
          ),
        ),
      ],
      Light(Vector3(0.0, 150.0, -1000)),
    )));
  }

  Future<void> loadImages() async {
    await loadAllImages({
      "grass": "assets/scenes/textures/grass.jpg",
      "clouds": "assets/scenes/textures/clouds.jpg",
      "dart": "assets/scenes/textures/dartflutter.png",
    });
  }

  Future<void> loadAllImages(Map<String, String> imagesNameUrl) {
    final waiters = <Future<void>>[];
    for (final fn in imagesNameUrl.entries) {
      waiters
          .add(FlutterImage.loadImage(fn.value)
          .then((a) => _allImages.add(_allImages.value..[fn.key] = a)));
    }
    return Future.wait(waiters);
  }
}