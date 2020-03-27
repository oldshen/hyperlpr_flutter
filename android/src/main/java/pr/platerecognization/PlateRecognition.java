package pr.platerecognization;

import pr.platerecognization.PlateInfo;

public class PlateRecognition {
    static {
        System.loadLibrary("hyperlpr");
    }
   public static native long InitPlateRecognizer(String casacde_detection,
                                           String finemapping_prototxt,String finemapping_caffemodel,
                                           String segmentation_prototxt,String segmentation_caffemodel,
                                           String charRecognization_proto,String charRecognization_caffemodel,
                                           String segmentationfree_proto, String segmentationfree_caffemodel);

   public static native void ReleasePlateRecognizer(long  object);
  public   static native String SimpleRecognization(long  inputMat,long object);
   public static native PlateInfo PlateInfoRecognization(long  inputMat, long object);
}
