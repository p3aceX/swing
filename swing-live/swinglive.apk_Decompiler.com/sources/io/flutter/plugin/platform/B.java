package io.flutter.plugin.platform;

import android.view.ViewTreeObserver;
import android.widget.FrameLayout;

/* JADX INFO: loaded from: classes.dex */
public final class B implements ViewTreeObserver.OnDrawListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final FrameLayout f4604a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public z f4605b;

    public B(FrameLayout frameLayout, z zVar) {
        this.f4604a = frameLayout;
        this.f4605b = zVar;
    }

    @Override // android.view.ViewTreeObserver.OnDrawListener
    public final void onDraw() {
        z zVar = this.f4605b;
        if (zVar == null) {
            return;
        }
        zVar.run();
        this.f4605b = null;
        this.f4604a.post(new z(this, 1));
    }
}
