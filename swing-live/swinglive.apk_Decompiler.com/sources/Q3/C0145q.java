package Q3;

/* JADX INFO: renamed from: Q3.q, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0145q extends AbstractC0140l0 implements InterfaceC0144p {
    public final q0 e;

    public C0145q(q0 q0Var) {
        this.e = q0Var;
    }

    @Override // Q3.InterfaceC0144p
    public final boolean c(Throwable th) {
        return l().B(th);
    }

    @Override // Q3.AbstractC0140l0
    public final boolean m() {
        return true;
    }

    @Override // Q3.AbstractC0140l0
    public final void n(Throwable th) {
        this.e.u(l());
    }
}
