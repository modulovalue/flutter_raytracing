import 'dart:ui' as ui;

import 'package:bird_flutter/bird_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_raytracing/pages/bloc_main.dart';

import 'bloc_scene.dart';

Widget mainWidget(void Function(String) openURL) {
  return $$ >> (context) {
    final sceneBloc = $$$(() => SceneBloc());
    final bloc = $$$(() {
      return MainBloc(sceneBloc.scene);
    });

    return apply
    & scaffold(color: Colors.black)
    & center()
    & singleChildScrollView()
        > onColumnMinCenterCenter()
            >> [
              apply
              & textSize(52.0)
              & textWeight800()
                  > onWrapCenterCenter(allSpacing: 6.0) >> [
                height(52.0) > const FlutterLogo(
                  size: 190.0,
                  textColor: Colors.white,
                  colors: Colors.red,
                  style: FlutterLogoStyle.horizontal,
                ),
                const Text("Raytracing"),
              ],

              verticalSpace(18.0),

              $$ >> (context) {
                final isLoadingImages = sceneBloc.isLoadingImages.hook;
                if (isLoadingImages) {
                  return const Text("Loading scene...");
                } else {
                  return nothing;
                }
              },

              verticalSpace(18.0),

              $$ >> (context) {
                final isRendering = bloc.isRendering.hook;
                final isLoadingImages = sceneBloc.isLoadingImages.hook;
                if (isLoadingImages) {
                  return nothing;
                } else if (isRendering) {
                  return textSize(24.0)
                  & textWeight100()
                      > const Text("Rendering...");
                } else {
                  return onWrapCenterCenter(allSpacing: 8.0) >> [
                    RaisedButton(
                      color: Colors.red[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: const Text("Render"),
                      onPressed: bloc.startRendering,
                    ),
                    RaisedButton(
                      color: Colors.red[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      child: const Text("Render Preview"),
                      onPressed: bloc.startPreviewRendering,
                    ),
                  ];
                }
              },

              verticalSpace(24.0),

              apply
              & clipCircular(8.0)
              & singleChildScrollViewH()
                  > $$ >> (context) {
                final _width = bloc.targetWidth.hook;
                final _height = bloc.targetHeight.hook;
                final scaling = bloc.scaling.hook;
                return bloc
                    .renderedImage
                    .hook
                    .fold(() => nothing, (image) {
                  return apply
                  & center()
                  & height(_height.toDouble())
                  & width(_width.toDouble())
                      > CustomPaint(painter: ImagePainter(image, scaling));
                });
              },

              verticalSpace(12.0),

              apply
              & textSize(9.0)
              & textColor(Colors.white.withOpacity(0.25))
                  > onWrapCenterCenter(allSpacing: 4.0) >> [
                onTap(() {
                  openURL("https://github.com/modulovalue/flutter_raytracing");
                }) > const Text("GitHub"),
                const Text("•"),
                onTap(() {
                  openURL("https://twitter.com/modulovalue");
                }) > const Text("@modulovalue"),
              ],
            ];
  };
}

class ImagePainter extends CustomPainter {
  final ui.Image image;
  final double scaling;

  const ImagePainter(this.image, this.scaling);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(scaling, scaling);
    canvas.drawImage(image, const Offset(0.0, 0.0), Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}