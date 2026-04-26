package io.flutter.plugin.platform;

import android.app.Activity;
import android.hardware.display.VirtualDisplay;
import android.widget.FrameLayout;

/* JADX INFO: loaded from: classes.dex */
public final class C {

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public static final y f4606i = new y();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public SingleViewPresentation f4607a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Activity f4608b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0425a f4609c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f4610d;
    public final int e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final h f4611f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public final l f4612g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public VirtualDisplay f4613h;

    public C(Activity activity, C0425a c0425a, VirtualDisplay virtualDisplay, y2.k kVar, h hVar, l lVar, int i4) {
        this.f4608b = activity;
        this.f4609c = c0425a;
        this.f4611f = hVar;
        this.f4612g = lVar;
        this.e = i4;
        this.f4613h = virtualDisplay;
        this.f4610d = activity.getResources().getDisplayMetrics().densityDpi;
        SingleViewPresentation singleViewPresentation = new SingleViewPresentation(activity, this.f4613h.getDisplay(), kVar, c0425a, i4, lVar);
        this.f4607a = singleViewPresentation;
        singleViewPresentation.show();
    }

    public final FrameLayout a() {
        SingleViewPresentation singleViewPresentation = this.f4607a;
        if (singleViewPresentation == null) {
            return null;
        }
        return ((y2.k) singleViewPresentation.getView()).f6916c;
    }
}
