package Q3;

import java.util.concurrent.CancellationException;
import y3.AbstractC0760a;

/* JADX INFO: loaded from: classes.dex */
public final class t0 extends AbstractC0760a implements InterfaceC0132h0 {

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public static final t0 f1659b = new t0(B.f1565b);

    @Override // Q3.InterfaceC0132h0
    public final boolean b() {
        return true;
    }

    @Override // Q3.InterfaceC0132h0
    public final CancellationException f() {
        throw new IllegalStateException("This job is always active");
    }

    @Override // Q3.InterfaceC0132h0
    public final boolean g() {
        return false;
    }

    @Override // Q3.InterfaceC0132h0
    public final boolean isCancelled() {
        return false;
    }

    @Override // Q3.InterfaceC0132h0
    public final boolean l() {
        return false;
    }

    @Override // Q3.InterfaceC0132h0
    public final O3.c p() {
        return O3.b.f1462a;
    }

    @Override // Q3.InterfaceC0132h0
    public final Q q(I3.l lVar) {
        return u0.f1664a;
    }

    public final String toString() {
        return "NonCancellable";
    }

    @Override // Q3.InterfaceC0132h0
    public final Q x(boolean z4, boolean z5, C0138k0 c0138k0) {
        return u0.f1664a;
    }

    @Override // Q3.InterfaceC0132h0
    public final Object y(A3.c cVar) {
        throw new UnsupportedOperationException("This job is always active");
    }

    @Override // Q3.InterfaceC0132h0
    public final InterfaceC0144p z(q0 q0Var) {
        return u0.f1664a;
    }

    @Override // Q3.InterfaceC0132h0
    public final void a(CancellationException cancellationException) {
    }
}
