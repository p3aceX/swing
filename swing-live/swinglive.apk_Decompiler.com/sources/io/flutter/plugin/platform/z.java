package io.flutter.plugin.platform;

import android.widget.FrameLayout;

/* JADX INFO: loaded from: classes.dex */
public final class z implements Runnable {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f4701a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ Object f4702b;

    public /* synthetic */ z(Object obj, int i4) {
        this.f4701a = i4;
        this.f4702b = obj;
    }

    @Override // java.lang.Runnable
    public final void run() {
        switch (this.f4701a) {
            case 0:
                A a5 = (A) this.f4702b;
                ((FrameLayout) a5.f4602b).postDelayed((m) a5.f4603c, 128L);
                break;
            default:
                B b5 = (B) this.f4702b;
                b5.f4604a.getViewTreeObserver().removeOnDrawListener(b5);
                break;
        }
    }
}
