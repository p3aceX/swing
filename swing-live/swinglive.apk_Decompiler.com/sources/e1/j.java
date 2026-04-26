package e1;

import X.N;
import u1.C0690c;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class j {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final j f3998b = new j(new N(7));

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public static final j f3999c = new j(new N(11));

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final i f4000a;

    static {
        new j(new N(13));
        new j(new N(12));
        new j(new N(8));
        new j(new N(10));
        new j(new N(9));
    }

    public j(N n4) {
        if (V0.a.a()) {
            this.f4000a = new C0779j(n4, 24);
        } else if ("The Android Project".equals(System.getProperty("java.vendor"))) {
            this.f4000a = new B.k(n4, 20);
        } else {
            this.f4000a = new C0690c(n4, 24);
        }
    }
}
