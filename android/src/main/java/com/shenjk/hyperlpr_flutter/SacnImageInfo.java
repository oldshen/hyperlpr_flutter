package com.shenjk.hyperlpr_flutter;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.renderscript.Allocation;
import android.renderscript.Element;
import android.renderscript.RenderScript;
import android.renderscript.ScriptIntrinsicYuvToRGB;
import android.renderscript.Type;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import io.flutter.plugin.common.MethodChannel;
import pr.platerecognization.PlateInfo;

class ScanImageInfo {
    private  int width;
    private  int height;
    List<byte[]> bytesList;
    @SuppressWarnings("unchecked")
    public  ScanImageInfo(HashMap<String,Object> args){
        this.width=(int)args.get("width");
        this.height=(int)args.get("height");
        this.bytesList= (ArrayList<byte[]>) args.get("byteList");
    }


    public void Scan(Context context, MethodChannel.Result result){
        Bitmap bitmap=null;
        if(bytesList.size()>1) {
            byte[] data = getYUVData();
            bitmap = convert2Bitmap(context, data, width, height);
        }else {
            bitmap=getOriginBitmap();   //原始图片信息，直接转换
        }
        PlateInfo plateInfo=  LprHelper.analyseImage(bitmap,8);
        bitmap.recycle();;
        if(plateInfo!=null && plateInfo.plateName!=null && plateInfo.plateName.length()>0){
            result.success(plateInfo.toMap());
        }else {
            result.success(null);
        }
    }
    private  Bitmap getOriginBitmap(){
        ByteBuffer byteBuffer=ByteBuffer.wrap(bytesList.get(0));
        byte[] bytes= byteBuffer.array();
        return  BitmapFactory.decodeByteArray(bytes,0,bytes.length);
    }

    private  byte[] getYUVData(){
        ByteBuffer Y = ByteBuffer.wrap(bytesList.get(0));
        ByteBuffer U = ByteBuffer.wrap(bytesList.get(1));
        ByteBuffer V = ByteBuffer.wrap(bytesList.get(2));

        BitmapFactory.Options newOpts = new BitmapFactory.Options();
        newOpts.inJustDecodeBounds = true;

        int Yb = Y.remaining();
        int Ub = U.remaining();
        int Vb = V.remaining();

        byte[] data = new byte[Yb + Ub + Vb];
        Y.get(data, 0, Yb);
        V.get(data, Yb, Vb);
        U.get(data, Yb + Vb, Ub);
        return  data;
    }

    private  static Bitmap convert2Bitmap(Context context,byte[] data, int width, int height){
        Bitmap bitmapRaw = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        Allocation bmData = renderScriptNV21ToRGBA888(
                context,
                width,
                height,
                data);
        bmData.copyTo(bitmapRaw);
        float rotation=90; //defualt
        Matrix matrix = new Matrix();
        matrix.postRotate(rotation);
        bitmapRaw = Bitmap.createBitmap(bitmapRaw, 0, 0, bitmapRaw.getWidth(), bitmapRaw.getHeight(), matrix, true);
        // saveBitmap("abc",bitmapRaw);
        return  bitmapRaw;
    }

    private static Allocation renderScriptNV21ToRGBA888(Context context, int width, int height, byte[] nv21) {
        // https://stackoverflow.com/a/36409748
        RenderScript rs = RenderScript.create(context);
        ScriptIntrinsicYuvToRGB yuvToRgbIntrinsic = ScriptIntrinsicYuvToRGB.create(rs, Element.U8_4(rs));

        Type.Builder yuvType = new Type.Builder(rs, Element.U8(rs)).setX(nv21.length);
        Allocation in = Allocation.createTyped(rs, yuvType.create(), Allocation.USAGE_SCRIPT);

        Type.Builder rgbaType = new Type.Builder(rs, Element.RGBA_8888(rs)).setX(width).setY(height);
        Allocation out = Allocation.createTyped(rs, rgbaType.create(), Allocation.USAGE_SCRIPT);

        in.copyFrom(nv21);

        yuvToRgbIntrinsic.setInput(in);
        yuvToRgbIntrinsic.forEach(out);
        return out;
    }
}