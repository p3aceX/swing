package A;

import android.view.Surface;
import android.view.SurfaceControl;
import android.view.WindowInsets;

/* JADX INFO: loaded from: classes.dex */
public abstract /* synthetic */ class K {
    public static /* synthetic */ Surface e(SurfaceControl surfaceControl) {
        return new Surface(surfaceControl);
    }

    public static /* synthetic */ SurfaceControl.Builder f() {
        return new SurfaceControl.Builder();
    }

    public static /* synthetic */ SurfaceControl.Transaction g() {
        return new SurfaceControl.Transaction();
    }

    public static /* synthetic */ WindowInsets.Builder i() {
        return new WindowInsets.Builder();
    }

    public static /* synthetic */ WindowInsets.Builder j(WindowInsets windowInsets) {
        return new WindowInsets.Builder(windowInsets);
    }

    public static /* synthetic */ void m() {
    }
}
