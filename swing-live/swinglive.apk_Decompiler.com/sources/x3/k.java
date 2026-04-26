package X3;

import V3.u;
import java.util.concurrent.TimeUnit;

/* JADX INFO: loaded from: classes.dex */
public abstract class k {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final String f2445a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final long f2446b;

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final int f2447c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final int f2448d;
    public static final long e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final g f2449f;

    static {
        String property;
        int i4 = u.f2250a;
        try {
            property = System.getProperty("kotlinx.coroutines.scheduler.default.name");
        } catch (SecurityException unused) {
            property = null;
        }
        if (property == null) {
            property = "DefaultDispatcher";
        }
        f2445a = property;
        f2446b = V3.b.k("kotlinx.coroutines.scheduler.resolution.ns", 100000L, 1L, Long.MAX_VALUE);
        int i5 = u.f2250a;
        if (i5 < 2) {
            i5 = 2;
        }
        f2447c = V3.b.l(i5, 8, "kotlinx.coroutines.scheduler.core.pool.size");
        f2448d = V3.b.l(2097150, 4, "kotlinx.coroutines.scheduler.max.pool.size");
        e = TimeUnit.SECONDS.toNanos(V3.b.k("kotlinx.coroutines.scheduler.keep.alive.sec", 60L, 1L, Long.MAX_VALUE));
        f2449f = g.f2440a;
    }
}
