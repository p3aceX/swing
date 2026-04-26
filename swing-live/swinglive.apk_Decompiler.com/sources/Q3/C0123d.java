package Q3;

/* JADX INFO: renamed from: Q3.d, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public final class C0123d implements InterfaceC0135j {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0121c[] f1619a;

    public C0123d(C0121c[] c0121cArr) {
        this.f1619a = c0121cArr;
    }

    @Override // Q3.InterfaceC0135j
    public final void a(Throwable th) {
        b();
    }

    public final void b() {
        for (C0121c c0121c : this.f1619a) {
            Q q4 = c0121c.f1616f;
            if (q4 == null) {
                J3.i.g("handle");
                throw null;
            }
            q4.a();
        }
    }

    public final String toString() {
        return "DisposeHandlersOnCancel[" + this.f1619a + ']';
    }
}
