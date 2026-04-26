package Q3;

import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;

/* JADX INFO: renamed from: Q3.j0, reason: case insensitive filesystem */
/* JADX INFO: loaded from: classes.dex */
public class C0136j0 extends q0 implements InterfaceC0147t {

    /* JADX INFO: renamed from: c, reason: collision with root package name */
    public final boolean f1634c;

    /* JADX WARN: 'super' call moved to the top of the method (can break code semantics) */
    public C0136j0(InterfaceC0132h0 interfaceC0132h0) {
        super(true);
        boolean z4 = true;
        L(interfaceC0132h0);
        AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = q0.f1657b;
        InterfaceC0144p interfaceC0144p = (InterfaceC0144p) atomicReferenceFieldUpdater.get(this);
        C0145q c0145q = interfaceC0144p instanceof C0145q ? (C0145q) interfaceC0144p : null;
        if (c0145q == null) {
            z4 = false;
            break;
        }
        q0 q0VarL = c0145q.l();
        while (!q0VarL.G()) {
            InterfaceC0144p interfaceC0144p2 = (InterfaceC0144p) atomicReferenceFieldUpdater.get(q0VarL);
            C0145q c0145q2 = interfaceC0144p2 instanceof C0145q ? (C0145q) interfaceC0144p2 : null;
            if (c0145q2 == null) {
                z4 = false;
                break;
            }
            q0VarL = c0145q2.l();
        }
        this.f1634c = z4;
    }

    @Override // Q3.q0
    public final boolean G() {
        return this.f1634c;
    }

    @Override // Q3.q0
    public final boolean H() {
        return true;
    }
}
