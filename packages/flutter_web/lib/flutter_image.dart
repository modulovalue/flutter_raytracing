import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

import 'package:flutter/services.dart';

class FlutterImage {
  final ui.Image image;
  final img.Image imgImage;
  final String path;

  const FlutterImage(this.path, this.image, this.imgImage);

  static Future<FlutterImage> loadImage(String path) async {
    final ByteData data = await rootBundle.load(path);
    final imgg = img.decodeImage(data.buffer.asUint8List());
    return FlutterImage(
      path,
      await () async {
        final completer = Completer<ui.Image>();
        ui.decodeImageFromList(
          Uint8List.view(data.buffer),
          completer.complete,
        );
        return completer.future;
      }(),
      imgg,
    );
  }
}