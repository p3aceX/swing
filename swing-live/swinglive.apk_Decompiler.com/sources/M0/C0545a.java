package m0;

import A.X;
import J3.i;
import android.content.Context;
import android.view.WindowInsets;
import android.view.WindowManager;

/* JADX INFO: renamed from: m0.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0545a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0545a f5762a = new C0545a();

    public final X a(Context context) {
        i.e(context, "context");
        WindowInsets windowInsets = ((WindowManager) context.getSystemService(WindowManager.class)).getCurrentWindowMetrics().getWindowInsets();
        i.d(windowInsets, "context.getSystemService…indowMetrics.windowInsets");
        return X.a(windowInsets, null);
    }
}
