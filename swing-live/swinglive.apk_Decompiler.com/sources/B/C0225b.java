package b;

import android.window.BackEvent;

/* JADX INFO: renamed from: b.b, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0225b {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final float f3205a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final float f3206b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final float f3207c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public final int f3208d;

    public C0225b(BackEvent backEvent) {
        C0224a c0224a = C0224a.f3204a;
        float fD = c0224a.d(backEvent);
        float fE = c0224a.e(backEvent);
        float fB = c0224a.b(backEvent);
        int iC = c0224a.c(backEvent);
        this.f3205a = fD;
        this.f3206b = fE;
        this.f3207c = fB;
        this.f3208d = iC;
    }

    public final String toString() {
        return "BackEventCompat{touchX=" + this.f3205a + ", touchY=" + this.f3206b + ", progress=" + this.f3207c + ", swipeEdge=" + this.f3208d + '}';
    }
}
