package y2;

import android.graphics.Bitmap;
import android.util.Log;

/* JADX INFO: loaded from: classes.dex */
public final /* synthetic */ class d implements w3.a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ g f6873a;

    public /* synthetic */ d(g gVar) {
        this.f6873a = gVar;
    }

    public final void c(Object obj, Integer num, Integer num2, Integer num3) {
        g gVar = this.f6873a;
        Bitmap bitmap = (Bitmap) obj;
        int iIntValue = num3.intValue();
        J3.i.e(bitmap, "bitmap");
        if (gVar.f6907z && iIntValue == gVar.f6895m.get()) {
            L1.a aVar = gVar.f6902t;
            try {
                aVar.f886y.f6642b = bitmap;
                Log.i("ImageStreamObject", "finish load image");
                aVar.f873B = true;
                aVar.h();
                aVar.g();
            } catch (Exception e) {
                Log.e("EliteStreamManager", "Filter update failed", e);
            }
        }
    }
}
