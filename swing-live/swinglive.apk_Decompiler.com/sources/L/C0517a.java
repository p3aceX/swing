package l;

import e1.AbstractC0367g;

/* JADX INFO: renamed from: l.a, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0517a extends AbstractC0367g {

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static volatile C0517a f5565d;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final C0520d f5566c = new C0520d();

    public static C0517a c0() {
        if (f5565d != null) {
            return f5565d;
        }
        synchronized (C0517a.class) {
            try {
                if (f5565d == null) {
                    f5565d = new C0517a();
                }
            } catch (Throwable th) {
                throw th;
            }
        }
        return f5565d;
    }
}
