import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:math' as math;

import 'package:hyperlpr_flutter/hyperlpr_flutter.dart';

/// true 继续扫描,false 停止扫描
typedef Future<bool> CameraCallback(String number, Uint8List bytes);

class CameraPreviewsController extends ValueNotifier<bool> {
  CameraPreviewsController(bool value) : super(value);

  contiueDetect() => value = false;
}

class CameraPrivewWidget extends StatefulWidget {
  final List<CameraDescription> cameras;
  final CameraCallback callback;
  final CameraPreviewsController controller;
  const CameraPrivewWidget(
      {Key key, this.cameras, this.controller, this.callback})
      : super(key: key);
  @override
  _CameraPrivewWidgetState createState() => _CameraPrivewWidgetState();
}

class _CameraPrivewWidgetState extends State<CameraPrivewWidget> {
  CameraController controller;
  bool isDetecting = false;
  @override
  void initState() {
    super.initState();
    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No camera is found');
      return;
    }
    controller = CameraController(widget.cameras[0], ResolutionPreset.max);

    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      widget?.controller?.addListener(() {
        isDetecting = widget?.controller?.value;
      });
      setState(() {});
      controller.startImageStream((CameraImage img) {
        if (!isDetecting) {
          isDetecting = true;
          HyperlprFlutter.scanImage(
                  img.planes.map((plane) => plane.bytes).toList(),
                  img.width,
                  img.height)
              .then((r) {
            if (r == null || !r.successed) {
              isDetecting = false;
            } else {
              print(r.number);
              SnackBar snackBar = SnackBar(
                content: Text(r.number),
                action: SnackBarAction(
                    label: "继续",
                    onPressed: () {
                      isDetecting = false;
                    }),
              );

              scaffoldKey.currentState.showSnackBar(snackBar);
              widget.callback?.call(r.number, r.bytes)?.then((c) {
                isDetecting = !c;
              });
            }
          });
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }
    var tmp =MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: Scaffold(
          key: scaffoldKey,
          body: CameraPreview(controller),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Icon(Icons.camera_alt),
          )),
    );
  }
}
