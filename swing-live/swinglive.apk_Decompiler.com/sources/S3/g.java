package S3;

import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public abstract class g {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public static final n f1830a = new n(-1, null, null, 0);

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final int f1831b = V3.b.l(32, 12, "kotlinx.coroutines.bufferedChannel.segmentSize");

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final int f1832c = V3.b.l(10000, 12, "kotlinx.coroutines.bufferedChannel.expandBufferCompletionWaitIterations");

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final C0779j f1833d;
    public static final C0779j e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final C0779j f1834f;

    /* JADX INFO: renamed from: g, reason: collision with root package name */
    public static final C0779j f1835g;

    /* JADX INFO: renamed from: h, reason: collision with root package name */
    public static final C0779j f1836h;

    /* JADX INFO: renamed from: i, reason: collision with root package name */
    public static final C0779j f1837i;

    /* JADX INFO: renamed from: j, reason: collision with root package name */
    public static final C0779j f1838j;

    /* JADX INFO: renamed from: k, reason: collision with root package name */
    public static final C0779j f1839k;

    /* JADX INFO: renamed from: l, reason: collision with root package name */
    public static final C0779j f1840l;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final C0779j f1841m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final C0779j f1842n;

    /* JADX INFO: renamed from: o, reason: collision with root package name */
    public static final C0779j f1843o;

    /* JADX INFO: renamed from: p, reason: collision with root package name */
    public static final C0779j f1844p;

    /* JADX INFO: renamed from: q, reason: collision with root package name */
    public static final C0779j f1845q;

    /* JADX INFO: renamed from: r, reason: collision with root package name */
    public static final C0779j f1846r;

    /* JADX INFO: renamed from: s, reason: collision with root package name */
    public static final C0779j f1847s;

    static {
        int i4 = 20;
        f1833d = new C0779j("BUFFERED", i4);
        e = new C0779j("SHOULD_BUFFER", i4);
        f1834f = new C0779j("S_RESUMING_BY_RCV", i4);
        f1835g = new C0779j("RESUMING_BY_EB", i4);
        f1836h = new C0779j("POISONED", i4);
        f1837i = new C0779j("DONE_RCV", i4);
        f1838j = new C0779j("INTERRUPTED_SEND", i4);
        f1839k = new C0779j("INTERRUPTED_RCV", i4);
        f1840l = new C0779j("CHANNEL_CLOSED", i4);
        f1841m = new C0779j("SUSPEND", i4);
        f1842n = new C0779j("SUSPEND_NO_WAITER", i4);
        f1843o = new C0779j("FAILED", i4);
        f1844p = new C0779j("NO_RECEIVE_RESULT", i4);
        f1845q = new C0779j("CLOSE_HANDLER_CLOSED", i4);
        f1846r = new C0779j("CLOSE_HANDLER_INVOKED", i4);
        f1847s = new C0779j("NO_CLOSE_CAUSE", i4);
    }
}
