package I;

import b.C0236m;
import java.util.concurrent.CancellationException;

/* JADX INFO: loaded from: classes.dex */
public final class g0 extends J3.j implements I3.l {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final /* synthetic */ C0236m f660a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ C0053n f661b;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public g0(C0236m c0236m, C0053n c0053n) {
        super(1);
        this.f660a = c0236m;
        this.f661b = c0053n;
    }

    @Override // I3.l
    public final Object invoke(Object obj) {
        w3.i iVar;
        w3.i iVar2;
        Throwable th = (Throwable) obj;
        this.f660a.invoke(th);
        C0053n c0053n = this.f661b;
        ((S3.e) c0053n.f708d).f(th, false);
        do {
            Object objA = ((S3.e) c0053n.f708d).A();
            iVar = null;
            if (objA instanceof S3.l) {
                objA = null;
            }
            iVar2 = w3.i.f6729a;
            if (objA != null) {
                ((d0) objA).f644b.d0(th == null ? new CancellationException("DataStore scope was cancelled before updateData could complete") : th);
                iVar = iVar2;
            }
        } while (iVar != null);
        return iVar2;
    }
}
