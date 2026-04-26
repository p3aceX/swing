package Q3;

/* JADX INFO: loaded from: classes.dex */
public final class F0 extends V3.r implements Runnable {
    public final long e;

    public F0(long j4, A3.c cVar) {
        super(cVar, cVar.getContext());
        this.e = j4;
    }

    @Override // Q3.q0
    public final String Q() {
        return super.Q() + "(timeMillis=" + this.e + ')';
    }

    @Override // java.lang.Runnable
    public final void run() {
        F.k(this.f1612c);
        u(new E0("Timed out waiting for " + this.e + " ms", this));
    }
}
