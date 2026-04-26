package Y3;

import I3.q;
import Q3.C0141m;
import Q3.InterfaceC0137k;
import Q3.K0;
import Q3.L;
import V3.s;
import java.lang.reflect.InvocationTargetException;
import java.util.concurrent.atomic.AtomicReferenceFieldUpdater;
import y3.InterfaceC0767h;
import z0.C0779j;

/* JADX INFO: loaded from: classes.dex */
public final class c implements InterfaceC0137k, K0 {

    /* JADX INFO: renamed from: a, reason: collision with root package name */
    public final C0141m f2527a;

    /* JADX INFO: renamed from: b, reason: collision with root package name */
    public final /* synthetic */ d f2528b;

    public c(d dVar, C0141m c0141m) {
        this.f2528b = dVar;
        this.f2527a = c0141m;
    }

    @Override // Q3.K0
    public final void a(s sVar, int i4) {
        this.f2527a.a(sVar, i4);
    }

    @Override // Q3.InterfaceC0137k
    public final C0779j e(Object obj, q qVar) {
        final d dVar = this.f2528b;
        q qVar2 = new q() { // from class: Y3.b
            @Override // I3.q
            public final Object b(Object obj2, Object obj3, Object obj4) {
                AtomicReferenceFieldUpdater atomicReferenceFieldUpdater = d.f2529g;
                this.getClass();
                d dVar2 = dVar;
                atomicReferenceFieldUpdater.set(dVar2, null);
                dVar2.e(null);
                return w3.i.f6729a;
            }
        };
        C0779j c0779jD = this.f2527a.D((w3.i) obj, qVar2);
        if (c0779jD != null) {
            d.f2529g.set(dVar, null);
        }
        return c0779jD;
    }

    @Override // y3.InterfaceC0762c
    public final InterfaceC0767h getContext() {
        return this.f2527a.e;
    }

    @Override // Q3.InterfaceC0137k
    public final void o(Object obj) throws L {
        this.f2527a.o(obj);
    }

    @Override // y3.InterfaceC0762c
    public final void resumeWith(Object obj) throws IllegalAccessException, L, InvocationTargetException {
        this.f2527a.resumeWith(obj);
    }
}
