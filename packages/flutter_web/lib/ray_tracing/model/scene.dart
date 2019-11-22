import 'dart:math';

import 'package:flutter_raytracing/ray_tracing/model/rgb.dart';
import 'package:flutter_raytracing/ray_tracing/objects/object_3d.dart';

import 'light.dart';
import 'ray.dart';

/// Holds all objects, lights, camera etc plus global details
class Scene {
  final List<Object3D> objs;
  final Light light;
  final int maxdepth = 2;

  const Scene(this.objs, this.light);

  @override
  String toString() =>
      'Scene{_objs: $objs, lights: $light, maxdepth: $maxdepth}';

  RGB shadeRay(Ray ray, int x, int y) => shadeRayForScene(this, ray, x, y);
}

RGB shadeRayForScene(Scene scene, Ray ray, int x, int y) {
  double t = double.infinity;
  Object3D hitObj;
  for (final Object3D obj in scene.objs) {
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
      ) * hitObj.style.material.ks;

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
