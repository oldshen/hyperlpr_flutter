package com.shenjk.hyperlpr_flutter;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.TextureRegistry;

/** HyperlprFlutterPlugin */
public class HyperlprFlutterPlugin implements FlutterPlugin, ActivityAware {
  private @Nullable
  MethodCallHandlerImpl methodCallHandler;

  private @Nullable FlutterPluginBinding flutterPluginBinding;

  private MethodChannel channel;
  private Context context;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    this.flutterPluginBinding=flutterPluginBinding;

  }

  private void maybeStartListening(
          Activity activity,
          BinaryMessenger messenger,
          TextureRegistry textureRegistry) {
    methodCallHandler=new MethodCallHandlerImpl(activity,messenger);

  }

  public static void registerWith(Registrar registrar) {

    HyperlprFlutterPlugin instance=new HyperlprFlutterPlugin();
    instance.maybeStartListening(registrar.activity(),registrar.messenger(),registrar.view());
  }



  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    this.flutterPluginBinding=null;
  }

  @Override
  public void onAttachedToActivity(ActivityPluginBinding binding) {
    maybeStartListening(binding.getActivity(),flutterPluginBinding.getBinaryMessenger(),flutterPluginBinding.getTextureRegistry());
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding binding) {
    onAttachedToActivity(binding);
  }

  @Override
  public void onDetachedFromActivity() {
    if (methodCallHandler == null) {
      // Could be on too low of an SDK to have started listening originally.
      return;
    }

    //methodCallHandler.stopListening();
    methodCallHandler = null;
  }
}
