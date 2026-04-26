package D2;

import android.view.ViewTreeObserver;

/* JADX INFO: renamed from: D2.f, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class ViewTreeObserverOnPreDrawListenerC0031f implements ViewTreeObserver.OnPreDrawListener {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ r f191a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0032g f192b;

    public ViewTreeObserverOnPreDrawListenerC0031f(C0032g c0032g, r rVar) {
        this.f192b = c0032g;
        this.f191a = rVar;
    }

    @Override // android.view.ViewTreeObserver.OnPreDrawListener
    public final boolean onPreDraw() {
        C0032g c0032g = this.f192b;
        if (c0032g.f199h && c0032g.f197f != null) {
            this.f191a.getViewTreeObserver().removeOnPreDrawListener(this);
            c0032g.f197f = null;
        }
        return c0032g.f199h;
    }
}
