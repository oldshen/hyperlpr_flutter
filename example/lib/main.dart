import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:hyperlpr_flutter/camera_previews.dart';
import 'package:hyperlpr_flutter/local_image.dart';

List<CameraDescription> cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HyperLPR for flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeApp(),
    );
  }
}

class HomeApp extends StatefulWidget {
  @override
  _HomeAppState createState() => _HomeAppState();
}

class _HomeAppState extends State<HomeApp> {
  @override
  void initState() {
    super.initState();
  }

  String number;
  Uint8List bytes;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("")),
      body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(number ?? ""),
            bytes != null ? Image.memory(bytes) : SizedBox(),
            RaisedButton(
                child: Text("选择本地图片"),
                onPressed: () async {
                  setState(() {
                    number="正在识别..";
                    bytes=null;
                  });
                  var res = await ScanLocalImage().scanImage(context);
                  if (res != null && res.successed) {
                    setState(() {
                      number = res.number;
                      bytes = res.bytes;
                    });
                  } else {
                    setState(() {
                      number = "识别失败";
                      bytes = null;
                    });
                  }
                }),
            RaisedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraPrivewWidget(
                          cameras: cameras,
                          callback: (n, bs) {
                            setState(() {
                              number = n;
                              bytes = bs;
                            });
                            Navigator.pop(context);
                            return Future.value(false);
                          },
                        ),
                      ));
                },
                child: Text("实时检测"))
          ]),
    );
  }
}
