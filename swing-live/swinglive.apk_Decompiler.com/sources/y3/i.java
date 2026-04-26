package Y3;

import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public abstract class i {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final C0779j f2539b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final C0779j f2540c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final C0779j f2541d;
    public static final C0779j e;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final int f2538a = V3.b.l(100, 12, "kotlinx.coroutines.semaphore.maxSpinCycles");

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final int f2542f = V3.b.l(16, 12, "kotlinx.coroutines.semaphore.segmentSize");

    static {
        int i4 = 20;
        f2539b = new C0779j("PERMIT", i4);
        f2540c = new C0779j("TAKEN", i4);
        f2541d = new C0779j("BROKEN", i4);
        e = new C0779j("CANCELLED", i4);
    }
}
