# 说明

该项目为在 [HyperLPR](https://github.com/lxhAndSmh/HyperLPR) 基础上实现`Flutter`版本；

下载代码后，进入example目录，执行`flutter run`，可以运行查看示例；

需要自行下载`opencv 4.2.0`版本，并按照下面的步骤配置；

# 配置

## Flutter 配置：

```
dependencies:
  flutter:
    sdk: flutter

  hyperlpr_flutter:
    path: ../
    # path 为hyperlpr_flutter所在目录
  camera: ^0.5.7+4
```

## Android下配置：
* 由于opencv过大，请自行下载 [OpenCV-android-sdk](https://opencv.org/releases/) 选择`4.2.0`版的[Android](https://sourceforge.net/projects/opencvlibrary/files/4.2.0/opencv-4.2.0-android-sdk.zip/download),下载后，解压，将`OpenCV-android-sdk/sdk/native`复制到 `hyperlpr_flutter/android/src/main/cpp/opencv420/sdk`目录下

* Android Gradle Plugin 最低版本要求：3.6.1

    ``` 
    dependencies {
        classpath 'com.android.tools.build:gradle:3.6.1'
    }
    ```

* Gradle 最低版本要求：5.6.4

    ```
    distributionUrl=https\://services.gradle.org/distributions/gradle-5.6.4-all.zip
    ```

* android minSdkVersion配置为 `21`:
   
    ```
    minSdkVersion 21
    targetSdkVersion 28
    ```

## iOS下配置：
* * 由于opencv过大，请自行下载 [OpenCV-android-sdk](https://opencv.org/releases/) 选择`4.2.0`版的[iOS Pack](https://sourceforge.net/projects/opencvlibrary/files/4.2.0/opencv-4.2.0-ios-framework.zip/download),下载后，解压，将`opencv2.framework`复制到 `hyperlpr_flutter/ios/`目录下
* 进入主工程的iOS目录，执行 `pod install`
* 修改主工程下的`Podfile`文件:

    ```
    platform : iOS '10.1'
    ```

* 再次执行 `pod install`
* 使用`xcode` 打开主工程的iOS项目：
  * Build Setting -> Compile Sources As 设置为 Objective-C++

