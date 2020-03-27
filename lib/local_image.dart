import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo/photo.dart';
import 'package:photo_manager/photo_manager.dart';
import 'hyperlpr_flutter.dart';

class ScanLocalImage with LoadingDelegate {
  @override
  Widget buildBigImageLoading(
      BuildContext context, AssetEntity entity, Color themeColor) {
    return Center(
      child: Container(
        width: 50.0,
        height: 50.0,
        child: CupertinoActivityIndicator(
          radius: 25.0,
        ),
      ),
    );
  }

  @override
  Widget buildPreviewLoading(
      BuildContext context, AssetEntity entity, Color themeColor) {
    return Center(
      child: Container(
        width: 50.0,
        height: 50.0,
        child: CupertinoActivityIndicator(
          radius: 25.0,
        ),
      ),
    );
  }

  Future<PlateResult> scanImage(BuildContext context,
      {List<AssetPathEntity> pathList}) async {
    List<AssetEntity> imgList = await PhotoPicker.pickAsset(
      context: context,
      themeColor: Colors.blue,
      textColor: Colors.white,
      padding: 1.0,
      dividerColor: Colors.grey,
      disableColor: Colors.grey.shade300,
      itemRadio: 0.88,
      maxSelected: 1,
      provider: I18nProvider.chinese,
      rowCount: 3,
      thumbSize: 150,
      sortDelegate: SortDelegate.common,
      checkBoxBuilderDelegate: DefaultCheckBoxBuilderDelegate(
        activeColor: Colors.white,
        unselectedColor: Colors.white,
        checkColor: Colors.red,
      ),
      loadingDelegate: this,
      badgeDelegate: const DurationBadgeDelegate(),
      pickType: PickType.onlyImage,
      photoPathList: pathList,
    );

    if (imgList == null || imgList.isEmpty) {
      return null;
    } else {
      AssetEntity entity = imgList.first;
      Uint8List bytes;
      if (Platform.isIOS) {
        /// iOS下存在heic格式图片，无法解析，所以先转换成jpeg格式；
        int w = entity.width.toInt();
        int h = entity.height.toInt();
        bytes = await entity.thumbDataWithSize(w, h, format: ThumbFormat.jpeg);
      } else if (Platform.isAndroid) {
        bytes = await entity.originBytes;
      }
      return HyperlprFlutter.scanLocalImage(bytes);
    }
  }
}
