package i0;

import j0.InterfaceC0450a;

/* JADX INFO: loaded from: classes.dex */
public final class b implements h {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final b f4458c;

    /* JADX INFO: renamed from: d, reason: collision with root package name */
    public static final b f4459d;
    public static final b e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public static final b f4460f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public static final b f4461m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public static final b f4462n;

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ int f4463a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final Object f4464b;

    static {
        int i4 = 0;
        f4458c = new b("NONE", i4);
        f4459d = new b("FULL", i4);
        int i5 = 1;
        e = new b("FLAT", i5);
        f4460f = new b("HALF_OPENED", i5);
        int i6 = 2;
        f4461m = new b("FOLD", i6);
        f4462n = new b("HINGE", i6);
    }

    public /* synthetic */ b(String str, int i4) {
        this.f4463a = i4;
        this.f4464b = str;
    }

    public String toString() {
        switch (this.f4463a) {
            case 0:
                return (String) this.f4464b;
            case 1:
                return (String) this.f4464b;
            case 2:
                return (String) this.f4464b;
            default:
                return super.toString();
        }
    }

    public b(InterfaceC0450a interfaceC0450a) {
        this.f4463a = 3;
        int i4 = n.f4486b;
        this.f4464b = interfaceC0450a;
    }
}
