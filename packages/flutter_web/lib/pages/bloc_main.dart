import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bird/bird.dart';
import 'package:flutter/material.dart' hide Material;
import 'package:flutter_raytracing/ray_tracing/model/camera.dart';
import 'package:flutter_raytracing/ray_tracing/model/ray.dart';
import 'package:flutter_raytracing/ray_tracing/model/scene.dart';
import 'package:image/image.dart' as img;
import 'package:vector_math/vector_math_64.dart' show Vector3;

// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: type_annotate_public_apis
class MainBloc extends HookBloc {
  final targetWidth = 650.$;
  final targetHeight = 320.$;

  /// Higher values mean lower quality but faster renderings
  final _scaling = 1.0.$;
  final isRendering = false.$;
  final renderingResult = none<RenderingResult>().$;
  final renderedImage = none<ui.Image>().$;

  Wave<int> scaledWidth;
  Wave<int> scaledHeight;
  Wave<Camera> camera;
  Wave<Option<Scene>> scene;
  Wave<double> scaling;

  MainBloc(Wave<Option<Scene>> _scene) {
    scaling = _scaling;
    scaledWidth = targetWidth
        .and(_scaling)
        .latest((v, s) => v ~/ s)
        .arm(later);
    scaledHeight = targetHeight
        .and(_scaling)
        .latest((v, s) => v ~/ s)
        .arm(later);
    camera = _scaling.map((s) {
      return Camera(
        ray: (width, height, x, y) {
          return Ray.pointAt(
            Vector3(0.0, 0.0, -1500.0),
            Vector3((x - (width / 2)) * s, ((height / 2) - y) * s, 0.0),
          );
        },
        intersection: Vector3.zero(),
        normal: Vector3.zero(),
      );
    }).arm(later);
    scene = _scene.arm(later);
  }

  Future<void> startRendering() {
    _scaling.add(1.0);
    return _startRendering();
  }

  Future<void> startPreviewRendering() {
    _scaling.add(8.0);
    return _startRendering();
  }

  Future<void> _startRendering() {
    return scene.value.fold(() async {
      /// No scene available
    }, (scene) async {
      isRendering.add(true);

      /// Give the UI time to respond to rendering status update
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final stopwatch = Stopwatch()
        ..start();

      final width = scaledWidth.value;
      final height = scaledHeight.value;

      final data = Uint8List(width * height * 4);

      iterate2D(width, height, (int x, int y, pos) {
        final clr = scene.shadeRay(camera.value.ray(width, height, x, y), x, y);
        data.setRange(pos, pos + 4, [
          (clr.r * 255.0).clamp(0, 255).floor(),
          (clr.g * 255.0).clamp(0, 255).floor(),
          (clr.b * 255.0).clamp(0, 255).floor(),
          255 - (clr.a * 255.0).clamp(0, 255).floor(),
        ]);
      });

      renderedImage.add(some((await (await ui.instantiateImageCodec(
        Uint8List.fromList(img.encodePng(
            img.Image.fromBytes(width, height, data))),
      ).catchError((dynamic a, dynamic b) => print("$a $b")))
          .getNextFrame()
          .catchError((dynamic a, dynamic b) => print("$a $b"))).image));

      stopwatch.stop();

      renderingResult.add(some(RenderingResult(
        timeToRender: stopwatch.elapsed,
      )));

      print(renderingResult.value);
      isRendering.add(false);
    }).catchError((dynamic a, dynamic b) => print("$a $b"));
  }
}

void iterate2D<T>(int width, int height,
    T Function(int x, int y, int pos) execute,
    {Rect region}) {
  final int rowStride = width * 4;
  int rowStart;
  int rowEnd;
  int colStart;
  int colEnd;
  if (region != null) {
    rowStart = region.top.floor();
    rowEnd = region.bottom.floor();
    colStart = region.left.floor();
    colEnd = region.right.floor();
    assert(rowStart >= 0);
    assert(rowEnd <= height);
    assert(colStart >= 0);
    assert(colEnd <= width);
  } else {
    rowStart = 0;
    rowEnd = height;
    colStart = 0;
    colEnd = width;
  }
  for (int row = rowStart; row < rowEnd; row++) {
    for (int col = colStart; col < colEnd; col++) {
      final int position = row * rowStride + col * 4;
      execute(col, row, position);
    }
  }
}

class RenderingResult {
  final Duration timeToRender;

  const RenderingResult({
    @required this.timeToRender,
  });

  @override
  String toString() =>
      'RenderingResult{timeToRender: $timeToRender}';
}
