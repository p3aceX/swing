package b;

import android.window.BackEvent;

/* JADX INFO: renamed from: b.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0224a {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final C0224a f3204a = new C0224a();

    public final BackEvent a(float f4, float f5, float f6, int i4) {
        return new BackEvent(f4, f5, f6, i4);
    }

    public final float b(BackEvent backEvent) {
        J3.i.e(backEvent, "backEvent");
        return backEvent.getProgress();
    }

    public final int c(BackEvent backEvent) {
        J3.i.e(backEvent, "backEvent");
        return backEvent.getSwipeEdge();
    }

    public final float d(BackEvent backEvent) {
        J3.i.e(backEvent, "backEvent");
        return backEvent.getTouchX();
    }

    public final float e(BackEvent backEvent) {
        J3.i.e(backEvent, "backEvent");
        return backEvent.getTouchY();
    }
}
