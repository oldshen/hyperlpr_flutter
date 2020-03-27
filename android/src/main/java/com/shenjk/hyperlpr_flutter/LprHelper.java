package com.shenjk.hyperlpr_flutter;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.os.Environment;
import android.util.Log;

import androidx.core.content.ContextCompat;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.InputStream;
import java.nio.file.Path;

import io.flutter.view.FlutterMain;
import pr.platerecognization.PlateInfo;
import pr.platerecognization.PlateRecognition;

import org.opencv.android.OpenCVLoader;
import org.opencv.android.Utils;
import org.opencv.core.CvType;
import org.opencv.core.Mat;
import org.opencv.core.Size;
import org.opencv.imgproc.Imgproc;

public class LprHelper {
    static {
        if(OpenCVLoader.initDebug())
        {
            Log.d("Opencv","opencv load_success");
        }
        else
        {
            Log.d("Opencv","opencv can't load opencv .");
        }
    }
    static  String[] assetsFiles=new String[]{
            "cascade.xml",
            "HorizonalFinemapping.prototxt",
            "HorizonalFinemapping.caffemodel",
            "Segmentation.prototxt",
            "Segmentation.caffemodel",
            "CharacterRecognization.prototxt",
            "CharacterRecognization.caffemodel",
            "SegmenationFree-Inception.prototxt",
            "SegmenationFree-Inception.caffemodel"
    };
    private static long handle;

    private static  boolean isInited=false;
    private static  final String packageName="hyperlpr_flutter";

    public static boolean hasStoragePermission(Context activity) {
        return ContextCompat.checkSelfPermission(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE)
                == PackageManager.PERMISSION_GRANTED;
    }
    /**
     * 注意：
     * 1、确保model文件存储在flutter层的assets/model目录下
     * 2、确保在 pubspec.yaml 中配置了资源路径信息，如：
     * assets:
     *    - assets/model
     *    - assets/model/cascade.xml
     *    - assets/model/CharacterRecognization.caffemodel
     *    - assets/model/CharacterRecognization.prototxt
     *    - assets/model/HorizonalFinemapping.caffemodel
     *    - assets/model/HorizonalFinemapping.prototxt
     *    - assets/model/SegmenationFree-Inception.caffemodel
     *    - assets/model/SegmenationFree-Inception.prototxt
     *    - assets/model/Segmentation.caffemodel
     *    - assets/model/Segmentation.prototxt
     *  3、需要在需要对存储的读写权限进行检查
     * */
    public static void initRecognizer(Context context)
    {
        if(isInited){
            return;
        }
        String rootPath=context.getFilesDir().getAbsolutePath();
        if(hasStoragePermission(context)){
            rootPath=Environment.getExternalStorageDirectory().getAbsolutePath();
        }
        String sdcardPath =combineAssetPath(rootPath,"pr");
        copyFilesFromAssets(context,sdcardPath);
        String cascade_filename  = combineAssetPath( sdcardPath,"cascade.xml");
        String finemapping_prototxt  =  combineAssetPath(sdcardPath,"HorizonalFinemapping.prototxt");
        String finemapping_caffemodel  = combineAssetPath( sdcardPath,"HorizonalFinemapping.caffemodel");
        String segmentation_prototxt =  combineAssetPath(sdcardPath,"Segmentation.prototxt");
        String segmentation_caffemodel =  combineAssetPath(sdcardPath,"Segmentation.caffemodel");
        String character_prototxt = combineAssetPath( sdcardPath,"CharacterRecognization.prototxt");
        String character_caffemodel=  combineAssetPath(sdcardPath,"CharacterRecognization.caffemodel");
        String segmentationfree_prototxt = combineAssetPath( sdcardPath,"SegmenationFree-Inception.prototxt");
        String segmentationfree_caffemodel=  combineAssetPath(sdcardPath,"SegmenationFree-Inception.caffemodel");

        handle  =  PlateRecognition.InitPlateRecognizer(
                cascade_filename,
                finemapping_prototxt,
                finemapping_caffemodel,
                segmentation_prototxt,
                segmentation_caffemodel,
                character_prototxt,
                character_caffemodel,
                segmentationfree_prototxt,
                segmentationfree_caffemodel
        );
        isInited=true;
    }
   private static String combineAssetPath(String sdcardPath,String fileName){
          return sdcardPath+File.separator+fileName;

   }

    private static void copyFilesFromAssets(Context context, String newPath) {
        try {
            File file = new File(newPath);
            file.mkdir();
            AssetManager assetManager=context.getAssets();
            for (String asset:assetsFiles) {

                String filePath=FlutterMain.getLookupKeyForAsset("assets/model/"+asset,packageName);

                String newFilePath= newPath+ File.separator+asset;
                InputStream is = assetManager.open(filePath);
                FileOutputStream fos = new FileOutputStream(new File(newFilePath));
                byte[] buffer = new byte[1024];
                int byteCount;
                while ((byteCount = is.read(buffer)) != -1) {
                    fos.write(buffer, 0, byteCount);
                }
                fos.flush();
                is.close();
                fos.close();
            }

        } catch (Exception e) {
            e.printStackTrace();
            Log.e("initRecognizer", "copyFilesFromAssets: "+e.getMessage().toString() );
        }
    }

    ///识别图片中的车牌信息
    public  static PlateInfo analyseImage(Bitmap bmp, int dp)
    {

        float dp_asp  = dp/10.f;
        Mat mat_src = new Mat(bmp.getWidth(), bmp.getHeight(), CvType.CV_8UC4);

        float new_w = bmp.getWidth()*dp_asp;
        float new_h = bmp.getHeight()*dp_asp;
        Size sz = new Size(new_w,new_h);
        Utils.bitmapToMat(bmp, mat_src);
        Imgproc.resize(mat_src,mat_src,sz);
//        long currentTime1 = System.currentTimeMillis();

        PlateInfo plateInfo = PlateRecognition.PlateInfoRecognization(mat_src.getNativeObjAddr(),handle);
        return plateInfo;

    }
}
