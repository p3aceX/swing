package androidx.lifecycle;

import android.os.Handler;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class y implements n {

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final y f3099o = new y();

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public int f3100a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public int f3101b;
    public Handler e;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public boolean f3102c = true;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public boolean f3103d = true;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final p f3104f = new p(this);

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final F1.a f3105m = new F1.a(this, 12);

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final C0779j f3106n = new C0779j(this, 22);

    public final void a() {
        int i4 = this.f3101b + 1;
        this.f3101b = i4;
        if (i4 == 1) {
            if (this.f3102c) {
                this.f3104f.e(EnumC0221g.ON_RESUME);
                this.f3102c = false;
            } else {
                Handler handler = this.e;
                J3.i.b(handler);
                handler.removeCallbacks(this.f3105m);
            }
        }
    }

    @Override // androidx.lifecycle.n
    public final p i() {
        return this.f3104f;
    }
}
