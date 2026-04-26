package Q3;

/* JADX INFO: loaded from: classes.dex */
public final class n0 extends AbstractC0140l0 {
    public final q0 e;

    /* JADX INFO: renamed from: f, reason: collision with root package name */
    public final o0 f1644f;

    /* JADX INFO: renamed from: m, reason: collision with root package name */
    public final C0145q f1645m;

    /* JADX INFO: renamed from: n, reason: collision with root package name */
    public final Object f1646n;

    public n0(q0 q0Var, o0 o0Var, C0145q c0145q, Object obj) {
        this.e = q0Var;
        this.f1644f = o0Var;
        this.f1645m = c0145q;
        this.f1646n = obj;
    }

    @Override // Q3.AbstractC0140l0
    public final boolean m() {
        return false;
    }

    @Override // Q3.AbstractC0140l0
    public final void n(Throwable th) {
        C0145q c0145q = this.f1645m;
        q0 q0Var = this.e;
        q0Var.getClass();
        C0145q c0145qR = q0.R(c0145q);
        o0 o0Var = this.f1644f;
        Object obj = this.f1646n;
        if (c0145qR == null || !q0Var.b0(o0Var, c0145qR, obj)) {
            o0Var.f1651a.f(new V3.i(2), 2);
            C0145q c0145qR2 = q0.R(c0145q);
            if (c0145qR2 == null || !q0Var.b0(o0Var, c0145qR2, obj)) {
                q0Var.r(q0Var.E(o0Var, obj));
            }
        }
    }
}
