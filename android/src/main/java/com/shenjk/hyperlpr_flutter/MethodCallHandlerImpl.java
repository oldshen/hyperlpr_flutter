package com.shenjk.hyperlpr_flutter;

import android.app.Activity;

import java.util.HashMap;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class MethodCallHandlerImpl implements MethodChannel.MethodCallHandler {

    private static final String PLUGIN_NAME = "com.shenjk/hyperlpr_flutter";
    private Activity mActivity;
    private  MethodChannel methodChannel;
    public MethodCallHandlerImpl(Activity activity, BinaryMessenger messenger){
        this.mActivity=activity;
        methodChannel = new MethodChannel(messenger, PLUGIN_NAME);
        methodChannel.setMethodCallHandler(this);
        LprHelper.initRecognizer(activity);
    }

    @SuppressWarnings("unchecked")
    @Override
    public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if(call.method.equals("scanImage")) {
            new ScanImageInfo((HashMap<String, Object>) call.arguments).Scan(mActivity,result);
        }else{
            result.notImplemented();
        }
    }
}
