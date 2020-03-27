import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class HyperlprFlutter {
  static const String _channel_name = "com.shenjk/hyperlpr_flutter";
  static const MethodChannel _channel = const MethodChannel(_channel_name);

  static Completer<void> _creatingCompleter;

  /// 实时检测相机图片
  /// Android下 为YUV格式的图片，所以参数是List<Uint8List> 交由native去解析
  static Future<PlateResult> scanImage(
      List<Uint8List> byteList, int w, int h) async {
    _creatingCompleter = Completer<void>();
    final Map<String, dynamic> result = await _channel
        .invokeMapMethod<String, dynamic>("scanImage",
            <String, dynamic>{"byteList": byteList, "width": w, "height": h});
    bool successed = result != null && result.isNotEmpty;
    String number;
    Uint8List bytes;
    if (successed) {
      number = result["number"];
      bytes = result["bytes"];
    }
    PlateResult plateResult =
        PlateResult(successed, number: number, bytes: bytes);

    _creatingCompleter.complete();
    return plateResult;
  }

  /// 检测本地图片
  /// [bytes] 图片数据，android下为文件原始数据，可以使用BitmapFactory生成bitmap;
  static Future<PlateResult> scanLocalImage(Uint8List bytes) async {
    assert(bytes != null);
    Uint8List bytesRes;
    int w = 0;
    int h = 0;
    if (Platform.isIOS) {
      ui.Image img = await getImage(bytes);
      w = img.width;
      h = img.height;
      ByteData data = await img.toByteData();
      bytesRes = new Uint8List.view(data.buffer);
    }else if(Platform.isAndroid){
      bytesRes=bytes;
    }
    assert(bytesRes != null);
    return scanImage([bytesRes], w, h);
  }
}

Future<ui.Image> getImage(Uint8List imageBytes) async {
  Completer<ImageInfo> completer = Completer();
  var img = new MemoryImage(imageBytes);
  img
      .resolve(ImageConfiguration())
      .addListener(ImageStreamListener((ImageInfo info, bool _) {
    completer.complete(info);
  }));

  ImageInfo imageInfo = await completer.future;
  return imageInfo.image;
}

class PlateResult {
  final bool successed;
  final Uint8List bytes;
  final String number;

  const PlateResult(this.successed, {this.bytes, this.number});

  @override
  String toString() {
    return "{successed:$successed,number:$number, bytes:$bytes}";
  }
}
